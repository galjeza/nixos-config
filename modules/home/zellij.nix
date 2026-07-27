{ ... }:
let
  # ── Single theme switch ──────────────────────────────────────────────
  # Flip this one value to re-theme zellij. It drives *both* zellij's native
  # UI (via settings.theme — a zellij built-in theme, or one of the `themes {}`
  # blocks below) and the zjstatus bar (whose hex colors the `theme` option
  # can't reach — hence the parallel `barPalettes` below, keyed off the same
  # name).
  # Options: "vague" | "moonfly" | "solarized-light" | "solarized-dark".
  # (vague + moonfly are custom themes defined in the `themes {}` block below;
  # the solarized variants ship as zellij built-ins. Each still needs a matching
  # bar palette here.)
  activeTheme = "moonfly";

  barPalettes = {
    vague = {
      bg = "#252530";
      sessionFg = "#6e94b2";
      modeNormal = "#6e94b2";
      modeTmux = "#f3be7c";
      tabNormal = "#606079";
      tabActive = "#cdcdcd";
      datetime = "#cdcdcd";
    };
    moonfly = {
      bg = "#080808";
      sessionFg = "#80A0FF";
      modeNormal = "#80A0FF";
      modeTmux = "#E3C78A";
      tabNormal = "#949494";
      tabActive = "#BDBDBD";
      datetime = "#BDBDBD";
    };
    solarized-light = {
      bg = "#eee8d5"; # base2
      sessionFg = "#268bd2"; # blue
      modeNormal = "#268bd2"; # blue
      modeTmux = "#b58900"; # yellow
      tabNormal = "#93a1a1"; # base1
      tabActive = "#586e75"; # base01
      datetime = "#657b83"; # base00
    };
    solarized-dark = {
      bg = "#073642"; # base02
      sessionFg = "#268bd2"; # blue
      modeNormal = "#268bd2"; # blue
      modeTmux = "#b58900"; # yellow
      tabNormal = "#586e75"; # base01
      tabActive = "#93a1a1"; # base1
      datetime = "#839496"; # base0
    };
  };
  bar = barPalettes.${activeTheme};
in
{
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      default_layout = "main";
      theme = activeTheme;
      pane_frames = false;
      show_release_notes = false;
      show_startup_tips = false;
    };
    layouts.main = ''
      layout {
          default_tab_template {
              children
              pane size=1 borderless=true {
                  plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
                      hide_frame_for_single_pane "false"

                      format_left  "{mode}#[fg=${bar.sessionFg},bg=${bar.bg},bold] {session}#[bg=${bar.bg}] {tabs}"
                      format_right "{datetime}"
                      format_space "#[bg=${bar.bg}]"

                      mode_normal          "#[bg=${bar.modeNormal}] "
                      mode_tmux            "#[bg=${bar.modeTmux}] "
                      mode_default_to_mode "tmux"

                      tab_normal               "#[fg=${bar.tabNormal},bg=${bar.bg}] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                      tab_active               "#[fg=${bar.tabActive},bg=${bar.bg},bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                      tab_fullscreen_indicator "□ "
                      tab_sync_indicator       "  "
                      tab_floating_indicator   "󰉈 "

                      datetime          "#[fg=${bar.datetime},bg=${bar.bg}] {format} "
                      datetime_format   "%A, %d %b %Y %H:%M"
                      datetime_timezone "Europe/Berlin"
                  }
              }
          }

          tab name="vim" {
              pane command="nvim" {
                  args "."
              }
          }

          tab name="terminal" {
              pane
          }

          tab name="agents" {
              pane command="claude" {
                  args "--dangerously-skip-permissions"
              }
          }
      }
    '';
    extraConfig = ''
      // Upstream: https://github.com/vague-theme/vague-zellij/blob/main/vague.kdl
      themes {
      	vague {
      		text_unselected {
      			base 205 205 205
      			background 20 20 21
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		text_selected {
      			base 205 205 205
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		ribbon_unselected {
      			base 37 37 48
      			background 205 205 205
      			emphasis_0 37 37 48
      			emphasis_1 205 205 205
      			emphasis_2 243 190 124
      			emphasis_3 187 157 189
      		}
      		ribbon_selected {
      			base 37 37 48
      			background 110 148 178
      			emphasis_0 37 37 48
      			emphasis_1 243 190 124
      			emphasis_2 187 157 189
      			emphasis_3 243 190 124
      		}
      		table_title {
      			base 127 165 99
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		table_cell_unselected {
      			base 205 205 205
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		table_cell_selected {
      			base 205 205 205
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		list_unselected {
      			base 205 205 205
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		list_selected {
      			base 205 205 205
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 110 148 178
      			emphasis_3 187 157 189
      		}
      		frame_selected {
      			base 174 174 209
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 174 174 209
      			emphasis_2 187 157 189
      			emphasis_3 37 37 48
      		}
      		frame_unselected {
      			base 96 96 121
      			background 96 96 121
      			emphasis_0 96 96 121
      			emphasis_1 96 96 121
      			emphasis_2 96 96 121
      			emphasis_3 96 96 121
      		}
      		frame_highlight {
      			base 243 190 124
      			background 37 37 48
      			emphasis_0 187 157 189
      			emphasis_1 243 190 124
      			emphasis_2 243 190 124
      			emphasis_3 243 190 124
      		}
      		exit_code_success {
      			base 127 165 99
      			background 37 37 48
      			emphasis_0 174 174 209
      			emphasis_1 37 37 48
      			emphasis_2 187 157 189
      			emphasis_3 243 190 124
      		}
      		exit_code_error {
      			base 216 100 126
      			background 37 37 48
      			emphasis_0 243 190 124
      			emphasis_1 37 37 48
      			emphasis_2 37 37 48
      			emphasis_3 37 37 48
      		}
      		multiplayer_user_colors {
      			player_1 187 157 189
      			player_2 243 190 124
      			player_3 37 37 48
      			player_4 174 174 209
      			player_5 216 100 126
      			player_6 37 37 48
      			player_7 127 165 99
      			player_8 37 37 48
      			player_9 37 37 48
      			player_10 37 37 48
      		}
      	}
      	// Upstream: https://github.com/bluz71/vim-moonfly-colors/blob/master/extras/moonfly-zellij.kdl
      	moonfly {
      		text_unselected {
      			base 189 189 189
      			background 8 8 8
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		text_selected {
      			base 189 189 189
      			background 64 64 64
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		ribbon_selected {
      			base 8 8 8
      			background 140 200 95
      			emphasis_0 216 51 75
      			emphasis_1 132 105 100
      			emphasis_2 171 101 217
      			emphasis_3 89 138 255
      		}
      		ribbon_unselected {
      			base 8 8 8
      			background 198 198 198
      			emphasis_0 216 51 75
      			emphasis_1 108 108 108
      			emphasis_2 89 138 255
      			emphasis_3 171 101 217
      		}
      		table_title {
      			base 140 200 95
      			background 0
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		table_cell_selected {
      			base 189 189 189
      			background 64 64 64
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		table_cell_unselected {
      			base 189 189 189
      			background 8 8 8
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		list_selected {
      			base 189 189 189
      			background 64 64 64
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		list_unselected {
      			base 189 189 189
      			background 8 8 8
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 140 200 95
      			emphasis_3 207 135 232
      		}
      		frame_selected {
      			base 140 200 95
      			background 0
      			emphasis_0 247 140 108
      			emphasis_1 121 218 200
      			emphasis_2 207 135 232
      			emphasis_3 0
      		}
      		frame_highlight {
      			base 247 140 108
      			background 0
      			emphasis_0 207 135 232
      			emphasis_1 247 140 108
      			emphasis_2 247 140 108
      			emphasis_3 247 140 108
      		}
      		exit_code_success {
      			base 140 200 95
      			background 0
      			emphasis_0 121 218 200
      			emphasis_1 8 8 8
      			emphasis_2 207 135 232
      			emphasis_3 128 160 255
      		}
      		exit_code_error {
      			base 230 94 114
      			background 0
      			emphasis_0 227 199 138
      			emphasis_1 0
      			emphasis_2 0
      			emphasis_3 0
      		}
      		multiplayer_user_colors {
      			player_1 207 135 232
      			player_2 128 160 255
      			player_3 0
      			player_4 227 199 138
      			player_5 121 218 200
      			player_6 0
      			player_7 230 94 114
      			player_8 0
      			player_9 0
      			player_10 0
      		}
      	}
      }
    '';
  };
}
