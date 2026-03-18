{ config, pkgs, ... }:
{
  wayland.windowManager.sway = {
    enable = true;
    config = rec {
      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";
      terminal = "foot";
      menu = "wmenu-run -N 191724 -n e0def4 -M 26233a -m e0def4 -S 31748f -s 191724";
      fonts = {
        names = [ "JetBrainsMono Nerd Font" ];
        size = 10.0;
      };

      colors = {
        focused = {
          border = "#31748f";
          background = "#31748f";
          text = "#e0def4";
          indicator = "#f6c177";
          childBorder = "#31748f";
        };
        focusedInactive = {
          border = "#26233a";
          background = "#26233a";
          text = "#6e6a86";
          indicator = "#26233a";
          childBorder = "#26233a";
        };
        unfocused = {
          border = "#191724";
          background = "#191724";
          text = "#6e6a86";
          indicator = "#191724";
          childBorder = "#191724";
        };
        urgent = {
          border = "#eb6f92";
          background = "#eb6f92";
          text = "#191724";
          indicator = "#eb6f92";
          childBorder = "#eb6f92";
        };
        placeholder = {
          border = "#191724";
          background = "#191724";
          text = "#6e6a86";
          indicator = "#191724";
          childBorder = "#191724";
        };
        background = "#191724";
      };

      output = {
        "*".bg = "${config.home.homeDirectory}/.wallpaper.png fill #191724";

        "Virtual-1".mode = "1920x1080@60Hz";
      };

      input = {
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
            "exec sh -c 'cliphist list | wmenu -i -l 20 -N 191724 -n e0def4 -M 26233a -m e0def4 -S 31748f -s 191724 | cliphist decode | wl-copy' ";

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
          statusCommand = "while date +'%Y-%m-%d %X'; do sleep 1; done";
          fonts = {
            names = [ "JetBrainsMono Nerd Font" ];
            size = 10.0;
          };
          colors = {
            statusline = "#e0def4";
            background = "#191724";
            inactiveWorkspace = {
              background = "#191724";
              border = "#191724";
              text = "#6e6a86";
            };
            activeWorkspace = {
              background = "#c4a7e7";
              border = "#c4a7e7";
              text = "#e0def4";
            };
            focusedWorkspace = {
              background = "#31748f";
              border = "#31748f";
              text = "#191724";
            };
          };
        }
      ];
    };
  };
}
