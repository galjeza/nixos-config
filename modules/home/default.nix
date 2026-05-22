{ config, pkgs, ... }:
{
  imports = [
    ./git.nix
    ./meld.nix
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

  home.file.".wallpaper.png".source = ../../assets/wallpapers/nix-wallpaper-waterfall.png;

programs.foot = {
  enable = true;
  settings = {
    main = {
      font = "JetBrainsMono Nerd Font:size=11";
    };

    colors-dark = {
      background = "141415";
      foreground = "cdcdcd";

      regular0 = "252530";
      regular1 = "d8647e";
      regular2 = "7fa563";
      regular3 = "f3be7c";
      regular4 = "6e94b2";
      regular5 = "bb9dbd";
      regular6 = "aeaed1";
      regular7 = "cdcdcd";

      bright0 = "606079";
      bright1 = "e08398";
      bright2 = "99b782";
      bright3 = "f5cb96";
      bright4 = "8ba9c1";
      bright5 = "c9b1ca";
      bright6 = "bebeda";
      bright7 = "d7d7d7";

      flash = "f3be7c";
      cursor = "141415 cdcdcd";

      selection-background = "252530";
      selection-foreground = "cdcdcd";
    };
  };
};
  services.mako = {
    enable = true;
    settings = {
      font = "JetBrainsMono Nerd Font 10";
      background-color = "#191724";
      text-color = "#e0def4";
      border-color = "#31748f";
      progress-color = "#31748f";
      default-timeout = 5000;
    };
  };

  services.polkit-gnome.enable = true;

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
    fastfetch
    zellij
    wdisplays
    zoxide
    lazygit
    nixfmt # formatting for nix files until i have neovim configured
    stylua
    tree-sitter
    gcc
    nodejs_24
    openssl
    prisma-engines
    pnpm
    grim
    slurp
    wl-clipboard
    cliphist
    nerd-fonts.jetbrains-mono
    thunar # gui file manager
    claude-code
    opencode
    htop
    slack
    gh
    ripgrep
    dbeaver-bin
    bruno
  ];
}
