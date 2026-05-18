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
      	  '';

    initContent = ''
      	    setopt inc_append_history
      	    eval "$(zoxide init zsh)"
      	  '';

    shellAliases = {
      vim = "nvim";
      vi = "nvim";
      im = "nvim";

      # NixOS rebuild helpers (Lenovo Yoga flake target)
      # Note: /etc/nixos is not a flake checkout here.
      rebuild = "sudo nixos-rebuild switch --flake $HOME/nixos-config#lenovo-yoga";
      rebuild-test = "sudo nixos-rebuild test --flake $HOME/nixos-config#lenovo-yoga";
      rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/nixos-config#lenovo-yoga";

      rebuild-update = "nix flake update $HOME/nixos-config && sudo nixos-rebuild switch --flake $HOME/nixos-config#lenovo-yoga";
    };
  };
}
