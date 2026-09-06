{ pkgs, ... }:
{
  imports = [
    ./foot.nix
    ./ghostty.nix
    ./git.nix
    ./meld.nix
    ./neovim.nix
    ./rust.nix
    ./sway.nix
    ./xdg.nix
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
      # monospace = [ "JetBrainsMono Nerd Font" ];
      monospace = [ "IoskeleyMono Nerd Font" ];
    };
  };

  # let home-manager manage itself
  programs.home-manager.enable = true;

  home.file.".wallpaper.jpg".source = ../../assets/wallpapers/grad.jpg;

  # Notification colours — vague palette (matches sway/swaylock chrome).
  services.mako = {
    enable = true;
    settings = {
      # font = "JetBrainsMono Nerd Font 10";
      font = "IoskeleyMono Nerd Font 10";
      background-color = "#141415";
      text-color = "#cdcdcd";
      border-color = "#6e94b2";
      progress-color = "#6e94b2";
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
    prisma-language-server # prismals — Prisma
    tailwindcss-language-server # tailwindcss — Tailwind CSS class completion/hover
    prettierd # conform prettier daemon (global fallback outside projects)

    tree-sitter
    gcc
    nodejs_24
    python3
    openssl
    prisma-engines
    pnpm
    grim
    slurp
    wl-clipboard
    cliphist
    pavucontrol
    # nerd-fonts.jetbrains-mono
    # Ioskeley Mono — Iosevka build shaped after Berkeley Mono (SIL OFL 1.1).
    # https://ahatem.github.io/IoskeleyMono/ — upstream recommends the plain
    # build for editors/UI and the -term build for terminals (strict cell
    # alignment). Nerd-Font-patched variants for icon glyphs.
    ioskeley-mono.normal-NF # family: "IoskeleyMono Nerd Font"
    ioskeley-mono.normal-term-NF # family: "IoskeleyMonoTerm Nerd Font"
    google-chrome
    firefox
    thunar # gui file manager
    loupe # gnome image viewer — opens svg, png, jpg, etc.
    libreoffice # office suite — open/view/edit docx (with images), odt, xlsx, etc.
    (anki.withAddons (with ankiAddons; [ anki-connect ]))
    claude-code
    opencode
    htop
    slack
    telegram-desktop
    obsidian
    gh
    ripgrep
    dbeaver-bin
    beyond-all-reason
    wineWow64Packages.stable # 32+64-bit Wine for electron-builder --win on Linux
    typst
  ];
}
