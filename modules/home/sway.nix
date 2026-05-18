{ config, pkgs, ... }:
let
  statusScript = pkgs.writeShellScript "sway-status" ''
    while true; do
      bat=$(cat /sys/class/power_supply/BAT0/capacity)
      echo "BAT: $bat% | $(date +'%Y-%m-%d %X')"
      sleep 1
    done
  '';
in
{
  wayland.windowManager.sway = {
    enable = true;
    extraConfig = ''
      default_border pixel 2
      default_floating_border pixel 2
    '';
    config = rec {
      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      terminal = "foot";
      menu = "wmenu-run -N 141415 -n cdcdcd -M 252530 -m cdcdcd -S 6e94b2 -s 141415";
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 10.0;
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
        "*".bg = "${config.home.homeDirectory}/.wallpaper.png fill #141415";

        "Virtual-1".mode = "1920x1080@60Hz";
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

          "${mod}+1" = "workspace number 1";
          "${mod}+2" = "workspace number 2";
          "${mod}+3" = "workspace number 3";
          "${mod}+4" = "workspace number 4";
          "${mod}+5" = "workspace number 5";
          "${mod}+6" = "workspace number 6";
          "${mod}+7" = "workspace number 7";
          "${mod}+8" = "workspace number 8";
          "${mod}+9" = "workspace number 9";
          "${mod}+0" = "workspace number 10";

          "${mod}+Shift+1" = "move container to workspace number 1";
          "${mod}+Shift+2" = "move container to workspace number 2";
          "${mod}+Shift+3" = "move container to workspace number 3";
          "${mod}+Shift+4" = "move container to workspace number 4";
          "${mod}+Shift+5" = "move container to workspace number 5";
          "${mod}+Shift+6" = "move container to workspace number 6";
          "${mod}+Shift+7" = "move container to workspace number 7";
          "${mod}+Shift+8" = "move container to workspace number 8";
          "${mod}+Shift+9" = "move container to workspace number 9";
          "${mod}+Shift+0" = "move container to workspace number 10";

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

      startup = [
        {
          command = "wl-paste --type text --watch cliphist store";
        }
        {
          command = "wl-paste --type image --watch cliphist store";
        }
      ];

      bars = [
        {
          position = "top";
          statusCommand = "${statusScript}";
          fonts = {
            names = [ "JetBrainsMono Nerd Font" ];
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
