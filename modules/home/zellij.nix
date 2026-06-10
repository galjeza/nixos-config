{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      simplified_ui = true;
      default_layout = "main";
      theme = "vague";
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

                format_left  "{mode}#[fg=#6E94B2,bg=#141415,bold] {session}#[bg=#141415] {tabs}"
                format_right "{datetime}"
                format_space "#[bg=#141415]"

                mode_normal          "#[bg=#6E94B2] "
                mode_tmux            "#[bg=#F3BE7C] "
                mode_default_to_mode "tmux"

                tab_normal               "#[fg=#606079,bg=#141415] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_active               "#[fg=#CDCDCD,bg=#141415,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                tab_fullscreen_indicator "□ "
                tab_sync_indicator       "  "
                tab_floating_indicator   "󰉈 "

                datetime          "#[fg=#CDCDCD,bg=#141415] {format} "
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
        pane command="claude --dangerously-skip-permissions"
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
