{ pkgs, ... }:
{
  imports = [
    ./android.nix
    ./foot.nix
    ./ghostty.nix
    ./git.nix
    ./lazygit.nix
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
      monospace = [ "IosevkaTerm Nerd Font Mono" ];
    };
  };

  # let home-manager manage itself
  programs.home-manager.enable = true;

  # Gemini CLI consumer sign-in was retired. Antigravity CLI (`agy`) is its
  # supported successor; its first launch imports compatible ~/.gemini state.
  # Keep its mutable settings unmanaged so OAuth and onboarding can persist.
  programs.antigravity-cli.enable = true;

  home.file.".wallpaper.jpg".source = ../../assets/wallpapers/grad.jpg;

  # Notification colours — vague palette (matches sway/swaylock chrome).
  services.mako = {
    enable = true;
    settings = {
      font = "IosevkaTerm Nerd Font Mono 10";
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
    copilot-language-server # copilot — GitHub Copilot via LSP (unfree; needs `:LspCopilotSignIn`)

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
    # Both installed so switching terminals/bars between them is a
    # font-name-only change (no big font download on rebuild).
    # Active family: "IosevkaTerm Nerd Font Mono".
    # Alternative: "Terminess Nerd Font Mono".
    nerd-fonts.iosevka-term
    nerd-fonts.terminess-ttf
    google-chrome
    firefox
    thunar # gui file manager
    loupe # gnome image viewer — opens svg, png, jpg, etc.
    libreoffice # office suite — open/view/edit docx (with images), odt, xlsx, etc.
    (anki.withAddons (with ankiAddons; [ anki-connect ]))
    claude-code
    opencode
    codex
    # Agent-aware multiplexer: detects which pane is running an agent and whether
    # it is working or blocked on you, so parallel agents don't need polling by
    # hand. It *is* a terminal multiplexer, so it overlaps zellij rather than
    # complementing it — both installed while trialling; drop one once decided.
    herdr
    htop
    slack
    telegram-desktop
    obsidian
    gh
    ripgrep
    difftastic # `difft` — structural (syntax-tree) diff; wired into lazygit
    dbeaver-bin
    beyond-all-reason
    wineWow64Packages.stable # 32+64-bit Wine for electron-builder --win on Linux
    typst
  ];
}
