{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      share = true;
    };

    sessionVariables = {
      EDITOR = "nvim";
      TERM = "xterm-256color";
      PNPM_HOME = "$HOME/.local/share/pnpm";
      PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
      PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
      PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
    };

    envExtra = ''
      	    path=(
      	      $HOME/.opencode/bin
      	      $HOME/.local/bin
      	      $HOME/bin
      	      $HOME/go/bin
      	      $HOME/.cargo/bin
      	      $HOME/.local/share/pnpm
      	      $path
      	    )

      	    [[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env

      	    # Per-machine secrets (GH_TOKEN, etc). NOT tracked in nix-config.
      	    [[ -f $HOME/.config/secrets/env ]] && source $HOME/.config/secrets/env
      	  '';

    initContent = ''
      	    setopt inc_append_history
      	    eval "$(zoxide init zsh)"

      	    # Prompt: ~/path on branch* ❯   (vague palette)
      	    autoload -Uz vcs_info
      	    precmd_vcs_info() { vcs_info }
      	    precmd_functions+=( precmd_vcs_info )
      	    setopt prompt_subst
      	    zstyle ':vcs_info:*' enable git
      	    zstyle ':vcs_info:git:*' check-for-changes true
      	    zstyle ':vcs_info:git:*' unstagedstr '*'
      	    zstyle ':vcs_info:git:*' stagedstr '+'
      	    zstyle ':vcs_info:git:*' formats ' %F{#606079}on%f %F{#f3be7c}%b%F{#d8647e}%u%c%f'
      	    zstyle ':vcs_info:git:*' actionformats ' %F{#606079}on%f %F{#f3be7c}%b|%a%F{#d8647e}%u%c%f'
      	    PROMPT='%n@%m:%F{#6e94b2}%~/%f''${vcs_info_msg_0_}
      > '

      	    ticket() {
      	      if [[ -z "$1" ]]; then
      	        echo "Usage:"
      	        echo "  ticket <name>       create worktree + start zellij session"
      	        echo "  ticket-done <name>  kill session + remove worktree"
      	        echo ""
      	        echo "Worktrees are created at ~/worktrees/<repo>/<name>"
      	        return 0
      	      fi
      	      local name="$1"
      	      local repo
      	      repo=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repo"; return 1; }
      	      local repo_name=$(basename "$repo")
      	      local worktree_dir="$HOME/worktrees/$repo_name/$name"

      	      if [[ ! -d "$worktree_dir" ]]; then
      	        git -C "$repo" worktree add "$worktree_dir" -b "$name"
      	      fi

      	      if zellij list-sessions -ns 2>/dev/null | grep -qx "$name"; then
      	        zellij attach "$name"
      	      else
      	        (cd "$worktree_dir" && zellij --session "$name" --new-session-with-layout main)
      	      fi
      	    }

      	    ticket-done() {
      	      local name="''${1:?Usage: ticket-done <name>}"
      	      local repo
      	      repo=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not in a git repo"; return 1; }
      	      local repo_name=$(basename "$repo")
      	      local worktree_dir="$HOME/worktrees/$repo_name/$name"

      	      zellij kill-session "$name" 2>/dev/null
      	      git worktree remove "$worktree_dir" --force
      	      echo "Done: $name"
      	    }
      	  '';

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      im = "nvim";
      zj = "zellij";

      # NixOS rebuild helpers (Lenovo Yoga flake target)
      # Note: /etc/nixos is not a flake checkout here.
      rebuild = "sudo nixos-rebuild switch --flake $HOME/nixos-config#lenovo-yoga";
      rebuild-test = "sudo nixos-rebuild test --flake $HOME/nixos-config#lenovo-yoga";
      rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/nixos-config#lenovo-yoga";

      rebuild-update = "nix flake update --flake $HOME/nixos-config && sudo nixos-rebuild switch --flake $HOME/nixos-config#lenovo-yoga";

      playwright-shell = "nix shell github:pietdevries94/playwright-web-flake#playwright-test";
    };
  };
}
