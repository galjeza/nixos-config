{ pkgs, theme, ... }:
{
  imports = [
    ./android.nix
    ./foot.nix
    ./git.nix
    ./lazygit.nix
    ./meld.nix
    ./neovim.nix
    ./rust.nix
    ./sway.nix
    ./theme.nix
    ./xdg.nix
    ./zellij.nix
    ./zsh.nix
  ];

  home.username = "galjeza";
  home.homeDirectory = "/home/galjeza";

  # this must match system.stateVersion in configuration.nix
  home.stateVersion = "25.11";

  # Monospace family comes from 'theme.nix' along with the palette.
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ theme.font ];
    };
  };

  # let home-manager manage itself
  programs.home-manager.enable = true;

  # Gemini CLI consumer sign-in was retired. Antigravity CLI (`agy`) is its
  # supported successor; its first launch imports compatible ~/.gemini state.
  # Keep its mutable settings unmanaged so OAuth and onboarding can persist.
  programs.antigravity-cli.enable = true;

  home.file.".wallpaper.jpg".source = ../../assets/wallpapers/grad.jpg;

  # Notification colours — from 'theme.nix', same palette as sway/swaylock.
  services.mako = {
    enable = true;
    settings = {
      font = "${theme.font} 10";
      background-color = "#${theme.colors.bg}";
      text-color = "#${theme.colors.fg}";
      border-color = "#${theme.colors.blue}";
      progress-color = "#${theme.colors.blue}";
      default-timeout = 5000;
    };
  };

  services.polkit-gnome.enable = true;

  # Installs zoxide *and* wires the `eval "$(zoxide init zsh)"` hook into zsh
  # itself, so neither the package nor the init line has to be repeated here.
  programs.zoxide.enable = true;

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
    fastfetch
    wdisplays
    nixfmt # nix formatter (wired into conform for .nix + nixd LSP)
    stylua

    # language servers + formatters (installed via nix, not mason)
    lua-language-server # lua_ls — Lua (this config)
    nixd # nixd — Nix
    vtsls # vtsls — TypeScript/JavaScript
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
    # font-name-only change (no big font download on rebuild). Which one is
    # live is the `font` line in 'theme.nix'.
    nerd-fonts.iosevka-term
    nerd-fonts.terminess-ttf
    google-chrome
    firefox
    thunar # gui file manager
    loupe # gnome image viewer — opens svg, png, jpg, etc.
    libreoffice # office suite — open/view/edit docx (with images), odt, xlsx, etc.
    claude-code
    opencode
    codex
    htop
    slack
    telegram-desktop
    obsidian
    gh
    ripgrep
    # Shell tooling coding agents reach for by default. rg covers text search;
    # these fill the rest — fd for file discovery, jq for every package.json /
    # `gh api` / `nix --json` payload, ast-grep for syntax-tree-aware search
    # where a regex gives false hits.
    fd
    jq
    # Its short binary name `sg` is shadowed by shadow's setgid `sg` in
    # /run/wrappers/bin, which wins on PATH. Invoke it as `ast-grep`.
    ast-grep
    tree
    file
    difftastic # `difft` — structural (syntax-tree) diff; wired into lazygit
    dbeaver-bin
    wineWow64Packages.stable # 32+64-bit Wine for electron-builder --win on Linux
  ];
}
