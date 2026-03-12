{ config, pkgs, ... }:
{
  # this must match your username
  home.username = "galjeza";
  home.homeDirectory = "/home/galjeza";

  # this must match system.stateVersion in configuration.nix
  home.stateVersion = "25.11";

  # let home-manager manage itself
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Gal Jeza";
    userEmail = "gal.jeza55@gmail.com";
  };
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
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
    };
  };

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
    neovim
    fastfetch
    firefox
    zellij
    waybar
    wofi
    wdisplays
    zoxide
    nixfmt-rfc-style # formatting for nix files until i have neovim configured
  ];

}
