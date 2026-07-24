{ config, pkgs, ... }:
{
  imports = [
    ./foot.nix
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

  home.file.".wallpaper.png".source = ../../assets/wallpapers/xp.jpg;

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
    nixfmt # nix formatter (wired into conform for .nix + nixd LSP)
    stylua

    # language servers + formatters (installed via nix, not mason)
    lua-language-server # lua_ls — Lua (this config)
    nixd # nixd — Nix
    vtsls # vtsls — TypeScript/JavaScript
    tinymist # tinymist — Typst LSP + typst-preview
    rust-analyzer # rust_analyzer — Rust
    rustfmt # conform rust formatter
    prisma-language-server # prismals — Prisma
    tailwindcss-language-server # tailwindcss — Tailwind CSS class completion/hover
    prettierd # conform prettier daemon (global fallback outside projects)

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
    pavucontrol
    nerd-fonts.jetbrains-mono
    thunar # gui file manager
    libreoffice # office suite — open/view/edit docx (with images), odt, xlsx, etc.
    claude-code
    opencode
    htop
    slack
    telegram-desktop
    gh
    ripgrep
    dbeaver-bin
    beyond-all-reason
    wineWowPackages.stable # 32+64-bit Wine for electron-builder --win on Linux
    typst
  ];
}
