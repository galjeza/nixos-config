{ config, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./neovim.nix
    ./sway.nix
    ./zsh.nix
  ];

  home.username = "galjeza";
  home.homeDirectory = "/home/galjeza";

  # this must match system.stateVersion in configuration.nix
  home.stateVersion = "25.11";

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  # let home-manager manage itself
  programs.home-manager.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };
    };
  };

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
    fastfetch
    firefox
    zellij
    waybar
    wdisplays
    zoxide
    lazygit
    nixfmt-rfc-style # formatting for nix files until i have neovim configured
    nodejs
    grim
    slurp
    wl-clipboard
    nerd-fonts.jetbrains-mono
    xfce.thunar # gui file manager
    opencode
  ];
}
