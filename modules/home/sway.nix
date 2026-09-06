{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  ws1 = "1: web"; # browser — daily web browsing, docs, GitHub PRs
  ws2 = "2: dev"; # zellij sessions — one per ticket (ticket PROJ-123)
  ws3 = "3: terminal"; # quick standalone terminals, one-off commands
  ws4 = "4: comms"; # Slack
  ws5 = "5: db"; # DBeaver — database inspection and queries
  ws6 = "6: api"; # Bruno — REST/GraphQL API testing
  ws7 = "7: linear + github"; # Linear tickets, GitHub PRs and Issues
  ws8 = "8: monitor"; # htop, logs, system health
  ws9 = "9: music"; # media playback
  ws10 = "10: scratch"; # overflow, floating windows, anything temporary

  # Shared across hosts, so the battery segment has to be optional — the
  # desktop has no BAT0 and the unguarded `cat` printed an error line into
  # the bar every second.
  statusScript = pkgs.writeShellScript "sway-status" ''
    while true; do
      if [ -r /sys/class/power_supply/BAT0/capacity ]; then
        echo "BAT: $(cat /sys/class/power_supply/BAT0/capacity)% | $(date +'%Y-%m-%d %X')"
      else
        date +'%Y-%m-%d %X'
      fi
      sleep 1
    done
  '';

  # Auto-suspend is a laptop affordance, and on `desktop` it is actively
  # destructive: S3 resume hangs that box. The one and only time the idle
  # ladder fired it (2026-09-06 19:30), the kernel logged `PM: suspend entry
  # (deep)` and never wrote another line — no resume, no panic, journal ends
  # there and the machine had to be power-cycled. Suspect is amdgpu (Navi 33)
  # or rtw89/RTL8852CE resume; both are common offenders and this host already
  # carries rtw89 ASPM workarounds. Until a *manual* `systemctl suspend`
  # round-trips cleanly there, the ladder stops at "screen off".
  suspendOnIdle = osConfig == null || osConfig.networking.hostName != "desktop";

  # Xwayland spans ONE X screen across the entire sway layout, and fullscreen
  # X11 games position themselves at that screen's origin. With two outputs
  # enabled, only one of them can own (0,0) — a game fullscreened on the other
  # one ends up offset from where sway draws it, so clicks land outside the
  # window while the keyboard still works (X routes keys by focus, not by
  # coordinate). That is the "I can't click anything in the game" bug.
  #
  # No static layout fixes both monitors at once. Game mode sidesteps it by
  # making the output you're playing on the ONLY active output, pinned to
  # (0,0) — so the X screen is exactly that monitor at the origin.
  #
  # Toggle with Mod+g (acts on the focused output, or pass an output name).
  gameMode = pkgs.writeShellScript "sway-game-mode" ''
    set -eu
    PATH=${
      pkgs.lib.makeBinPath [
        pkgs.sway
        pkgs.jq
        pkgs.libnotify
      ]
    }:$PATH
    state="''${XDG_RUNTIME_DIR:-/tmp}/sway-game-mode"

    if [ -e "$state" ]; then
      # Restore: re-enable everything (disabled outputs are still listed by
      # get_outputs), then reload to re-apply the declared positions.
      swaymsg -t get_outputs | jq -r '.[].name' | while read -r out; do
        swaymsg output "$out" enable >/dev/null
      done
      rm -f "$state"
      swaymsg reload >/dev/null
      notify-send -t 2000 "Game mode off" "All outputs restored"
      exit 0
    fi

    target="''${1:-$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')}"
    if [ -z "$target" ] || [ "$target" = "null" ]; then
      notify-send -u critical "Game mode" "Could not determine target output"
      exit 1
    fi

    swaymsg -t get_outputs \
      | jq -r --arg t "$target" '.[] | select(.active and .name != $t) | .name' \
      | while read -r out; do swaymsg output "$out" disable >/dev/null; done
    swaymsg output "$target" pos 0 0 >/dev/null

    touch "$state"
    notify-send -t 2000 "Game mode on" "$target is the only output, pinned to 0,0"
  '';

  # AnyDesk hardcodes DISPLAY=:0 for its child processes. When sway's
  # Xwayland lands on :1 (or later), those children fail with "Cannot open
  # display" and AnyDesk auto-shuts-down. Point /tmp/.X11-unix/X0 at
  # whichever socket Xwayland actually picked.
  xwaylandX0Symlink = pkgs.writeShellScript "xwayland-x0-symlink" ''
    shopt -s nullglob
    for _ in $(seq 1 30); do
      if [ -S /tmp/.X11-unix/X0 ]; then exit 0; fi
      for sock in /tmp/.X11-unix/X[0-9]*; do
        if [ -S "$sock" ]; then
          ln -sf "$sock" /tmp/.X11-unix/X0
          exit 0
        fi
      done
      sleep 0.5
    done
  '';
in
{
  programs.swaylock = {
    enable = true;
    settings = {
      color = "141415";
      # font = "JetBrainsMono Nerd Font";
      font = "IoskeleyMono Nerd Font";
      font-size = 24;
      indicator-idle-visible = false;
      indicator-radius = 100;
      show-failed-attempts = true;
    };
  };
  # Idle ladder: lock at 5min, screen off at 10min, suspend at 15min — the
  # last rung only on hosts where resume works (see suspendOnIdle above).
  # Also lock before any suspend (incl. lid close) and on systemd lock signal;
  # those stay wired up everywhere so a *manual* suspend still locks first.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${pkgs.swaylock}/bin/swaylock -f";
      lock = "${pkgs.swaylock}/bin/swaylock -f";
    };
    timeouts = [
      {
        timeout = 300;
        command = "${pkgs.swaylock}/bin/swaylock -f";
      }
      {
        timeout = 600;
        command = ''${pkgs.sway}/bin/swaymsg "output * power off"'';
        resumeCommand = ''${pkgs.sway}/bin/swaymsg "output * power on"'';
      }
    ]
    ++ lib.optional suspendOnIdle {
      timeout = 900;
      command = "${pkgs.systemd}/bin/systemctl suspend";
    };
  };
  wayland.windowManager.sway = {
    enable = true;
    extraConfig = ''
      # Steam/Proton games run under XWayland and auto-fullscreen so the window
      # maps 1:1 to the output. Combined with the internal panel being pinned
      # to (0,0) below, this is what fixes "can't click buttons" in games —
      # a fullscreen X11 game positions itself at the X screen origin, so an
      # empty (0,0) makes every click land in the wrong place.
      for_window [class="^steam_app_[0-9]+$"] fullscreen enable
    '';
    config = rec {
      focus.followMouse = false;
      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      terminal = "ghostty";
      menu = "wmenu-run -N 141415 -n cdcdcd -M 252530 -m cdcdcd -S 6e94b2 -s 141415";
      fonts = {
        # names = [ "JetBrainsMono Nerd Font" ];
        names = [ "IoskeleyMono Nerd Font" ];
        size = 10.0;
      };

      # No borders and no titlebars anywhere — the 6px gap is the only thing
      # separating windows. `border = 0` emits `default_border pixel 0`, which
      # is sway's `none`. (smart_borders is pointless with no borders to hide.)
      window = {
        titlebar = false;
        border = 0;
      };
      floating = {
        titlebar = false;
        border = 0;
      };

      gaps = {
        inner = 6;
        outer = 0;
        # No gaps at all when a workspace has a single container.
        smartGaps = true;
      };

      colors = {
        focused = {
          border = "#6e94b2";
          background = "#6e94b2";
          text = "#141415";
          indicator = "#f3be7c";
          childBorder = "#6e94b2";
        };
        focusedInactive = {
          border = "#252530";
          background = "#252530";
          text = "#606079";
          indicator = "#252530";
          childBorder = "#252530";
        };
        unfocused = {
          border = "#141415";
          background = "#141415";
          text = "#606079";
          indicator = "#141415";
          childBorder = "#141415";
        };
        urgent = {
          border = "#d8647e";
          background = "#d8647e";
          text = "#141415";
          indicator = "#d8647e";
          childBorder = "#d8647e";
        };
        placeholder = {
          border = "#141415";
          background = "#141415";
          text = "#606079";
          indicator = "#141415";
          childBorder = "#141415";
        };
        background = "#141415";
      };

      output = {
        "*".bg = "${config.home.homeDirectory}/.wallpaper.jpg fill #141415";

        "Virtual-1".mode = "1920x1080@60Hz";

        # The internal panel owns the layout origin (0,0); the external ASUS
        # sits to its right. This ordering matters for XWayland games:
        # Xwayland spans a single X screen over the whole sway layout, and
        # fullscreen X11 games place themselves at that screen's origin. If
        # no output occupies (0,0), the game's idea of its own position is
        # offset from where sway actually draws it, so every click lands off
        # the window while the keyboard keeps working (X routes keys by
        # focus, not by coordinate) — the "can't click anything in the game"
        # bug.
        #
        # The origin therefore belongs to the output that is ALWAYS present.
        # Pinning the external monitor there instead left a phantom 1920px
        # dead zone at (0,0) whenever it was unplugged — which is exactly
        # when the bug reappeared.
        #
        # eDP-1 is 3200x2000 at scale 2 => 1600x1000 logical, so the ASUS
        # starts at x=1600.
        "China Star Optoelectronics Technology Co., Ltd 0x1640 0x00006004" = {
          mode = "3200x2000@165Hz";
          pos = "0 0";
        };
        "ASUSTek COMPUTER INC VY279HGR T7LMTF134179" = {
          mode = "1920x1080@100Hz";
          pos = "1600 0";
        };

        # desktop: Xiaomi 34" ultrawide on HDMI-A-2. Its EDID marks the
        # 3440x1440@50Hz mode as *preferred*, so sway lands on 49.998Hz
        # unless told otherwise. Sway has no "fastest mode" keyword, but when
        # the requested refresh has no exact match it falls back to the
        # highest refresh at that resolution — so "@100Hz" resolves to the
        # real 99.992Hz here, and would pick up 144Hz on its own if the
        # monitor is moved to DisplayPort (HDMI caps this panel at 100Hz).
        "Xiaomi Corporation Mi Monitor 0000000000000" = {
          mode = "3440x1440@100Hz";
          pos = "0 0";
        };
      };

      input = {
        "*" = {
          repeat_delay = "200";
          repeat_rate = "50";
        };
        "type:tablet" = {
          map_to_output = "Virtual-1";
        };
      };

      # keybindings
      keybindings =
        let
          mod = modifier;
        in
        {
          "${mod}+Return" = "exec ${terminal}";
          "${mod}+Shift+q" = "kill";
          "${mod}+d" = "exec ${menu}";
          "${mod}+Shift+c" = "reload";
          "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";
          "${mod}+Shift+s" =
            ''exec sh -c 'mkdir -p ~/Pictures/Screenshots && file=~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png && grim -g "$(slurp)" "$file" && wl-copy -t image/png < "$file"' '';
          "${mod}+Shift+v" =
            "exec sh -c 'cliphist list | wmenu -i -l 20 -N 141415 -n cdcdcd -M 252530 -m cdcdcd -S 6e94b2 -s 141415 | cliphist decode | wl-copy' ";

          "${mod}+${left}" = "focus left";

          "${mod}+${down}" = "focus down";
          "${mod}+${up}" = "focus up";
          "${mod}+${right}" = "focus right";
          "${mod}+Left" = "focus left";
          "${mod}+Down" = "focus down";
          "${mod}+Up" = "focus up";
          "${mod}+Right" = "focus right";

          "${mod}+Shift+${left}" = "move left";
          "${mod}+Shift+${down}" = "move down";
          "${mod}+Shift+${up}" = "move up";
          "${mod}+Shift+${right}" = "move right";
          "${mod}+Shift+Left" = "move left";
          "${mod}+Shift+Down" = "move down";
          "${mod}+Shift+Up" = "move up";
          "${mod}+Shift+Right" = "move right";

          "${mod}+1" = "workspace \"${ws1}\"";
          "${mod}+2" = "workspace \"${ws2}\"";
          "${mod}+3" = "workspace \"${ws3}\"";
          "${mod}+4" = "workspace \"${ws4}\"";
          "${mod}+5" = "workspace \"${ws5}\"";
          "${mod}+6" = "workspace \"${ws6}\"";
          "${mod}+7" = "workspace \"${ws7}\"";
          "${mod}+8" = "workspace \"${ws8}\"";
          "${mod}+9" = "workspace \"${ws9}\"";
          "${mod}+0" = "workspace \"${ws10}\"";

          "${mod}+Shift+1" = "move container to workspace \"${ws1}\"";
          "${mod}+Shift+2" = "move container to workspace \"${ws2}\"";
          "${mod}+Shift+3" = "move container to workspace \"${ws3}\"";
          "${mod}+Shift+4" = "move container to workspace \"${ws4}\"";
          "${mod}+Shift+5" = "move container to workspace \"${ws5}\"";
          "${mod}+Shift+6" = "move container to workspace \"${ws6}\"";
          "${mod}+Shift+7" = "move container to workspace \"${ws7}\"";
          "${mod}+Shift+8" = "move container to workspace \"${ws8}\"";
          "${mod}+Shift+9" = "move container to workspace \"${ws9}\"";
          "${mod}+Shift+0" = "move container to workspace \"${ws10}\"";

          "${mod}+b" = "splith";
          "${mod}+v" = "splitv";
          "${mod}+s" = "layout stacking";
          "${mod}+w" = "layout tabbed";
          "${mod}+e" = "layout toggle split";
          "${mod}+f" = "fullscreen";
          "${mod}+Shift+space" = "floating toggle";
          "${mod}+space" = "focus mode_toggle";
          "${mod}+a" = "focus parent";
          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+minus" = "scratchpad show";
          "${mod}+r" = "mode resize";
          # Toggle single-output "game mode" — see gameMode above.
          "${mod}+g" = "exec ${gameMode}";
        };

      modes = {
        resize = {
          "${left}" = "resize shrink width 10px";
          "${down}" = "resize grow height 10px";
          "${up}" = "resize shrink height 10px";
          "${right}" = "resize grow width 10px";
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px";
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      # blueman-applet is only installed on hosts that enable bluetooth. The
      # desktop deliberately doesn't (its Wi-Fi/BT combo card shares one
      # antenna), so autostarting it there would just fail every login.
      startup = [
        {
          command = "wl-paste --type text --watch cliphist store";
        }
        {
          command = "wl-paste --type image --watch cliphist store";
        }
      ]
      ++ lib.optional (osConfig == null || osConfig.hardware.bluetooth.enable) {
        command = "blueman-applet";
      }
      ++ [
        {
          command = "${xwaylandX0Symlink}";
        }
      ];

      bars = [
        {
          position = "top";
          statusCommand = "${statusScript}";
          fonts = {
            # names = [ "JetBrainsMono Nerd Font" ];
            names = [ "IoskeleyMono Nerd Font" ];
            size = 10.0;
          };
          colors = {
            statusline = "#cdcdcd";
            background = "#141415";
            inactiveWorkspace = {
              background = "#141415";
              border = "#141415";
              text = "#606079";
            };
            activeWorkspace = {
              background = "#252530";
              border = "#252530";
              text = "#cdcdcd";
            };
            focusedWorkspace = {
              background = "#6e94b2";
              border = "#6e94b2";
              text = "#141415";
            };
          };
        }
      ];
    };
  };
}
