{ config, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./neovim.nix
    ./sway.nix
    ./zellij.nix
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

  home.file.".wallpaper.png".source = ../../wallpaper.png;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };
      colors = {
        background = "191724";
        foreground = "e0def4";
        regular0 = "26233a";
        regular1 = "eb6f92";
        regular2 = "9ccfd8";
        regular3 = "f6c177";
        regular4 = "31748f";
        regular5 = "c4a7e7";
        regular6 = "ebbcba";
        regular7 = "e0def4";
        bright0 = "47435d";
        bright1 = "ff98ba";
        bright2 = "c5f9ff";
        bright3 = "ffeb9e";
        bright4 = "5b9ab7";
        bright5 = "eed0ff";
        bright6 = "ffe5e3";
        bright7 = "fefcff";
        flash = "f6c177";
        cursor = "191724 e0def4";
      };
    };
  };

  services.mako = {
    enable = true;
    font = "JetBrainsMono Nerd Font 10";
    backgroundColor = "#191724";
    textColor = "#e0def4";
    borderColor = "#31748f";
    progressColor = "#31748f";
    defaultTimeout = 5000;
  };

  services.polkit-gnome.enable = true;

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
    fastfetch
    firefox
    zellij
    wdisplays
    zoxide
    lazygit
    nixfmt-rfc-style # formatting for nix files until i have neovim configured
    nodejs
    grim
    slurp
    wl-clipboard
    cliphist
    nerd-fonts.jetbrains-mono
    xfce.thunar # gui file manager
    claude-code
    opencode
    htop
  ];
}
