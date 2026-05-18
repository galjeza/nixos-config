{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = false;
      pane_frames = true;
      default_layout = "main";
      theme = "vague";
      show_release_notes = false;
      show_startup_tips = false;
    };
    layouts.main = ''
layout {
  default_tab_template {
      pane size=1 borderless=true {
        plugin location="https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
          format_left  "#[bg=green,fg=black] {session} {tabs}"
          format_center "#[bg=green,fg=black] "
          format_right "#[bg=green,fg=black] {mode} {command_host} {datetime} "
          format_space  "#[bg=green]"

          command_host_command  "hostname"
          command_host_format   "{stdout}"
          command_host_interval "60"
          command_host_rendermode "static"

          mode_normal        "normal"
          mode_locked        " locked"
          mode_resize        "resize"
          mode_pane          "pane"
          mode_tab           "tab"
          mode_scroll        "scroll"
          mode_enter_search  "enter_search"
          mode_search        "search"
          mode_rename_tab    "rename_tab"
          mode_rename_pane   "rename_pane"
          mode_session       "session"
          mode_move          "move"
          mode_prompt        "prompt"
          mode_tmux          "tmux"

          tab_normal "#[bg=green,fg=black] #[bg=green,fg=black]{index}:{name} {sync_indicator}{fullscreen_indicator}{floating_indicator}#[bg=green,fg=black]"
          tab_active "#[bg=green,fg=black] #[bg=green,fg=black]{index}:{name}* {sync_indicator}{fullscreen_indicator}{floating_indicator}#[bg=green,fg=black]"

          tab_sync_indicator       "󰓦 "
          tab_fullscreen_indicator "󱟱  "
          tab_floating_indicator   "󰉈 "

          datetime          "{format}"
          datetime_format   "%d-%m-%Y %H:%M"
          datetime_timezone "Europe/Berlin"
        }
      }
    children
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
}
    '';
  };
}
