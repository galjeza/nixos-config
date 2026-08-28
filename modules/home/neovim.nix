{ config, pkgs, ... }:
{
  # Neovim nightly, via the overlay wired up in flake.nix.
  #
  # Deliberately NOT home-manager's `programs.neovim` module: that module always
  # generates its own '.config/nvim/init.lua' (to set the `loaded_*_provider`
  # flags), which collides with the whole-directory symlink below and fails the
  # build with "Error installing file '.config/nvim/init.lua' outside $HOME".
  # The provider flags now live at the top of 'nvim/init.lua' instead.
  home.packages = [ pkgs.neovim ];

  # `vi` / `vim` aliases are in zsh.nix; this replaces `programs.neovim.defaultEditor`.
  home.sessionVariables.EDITOR = "nvim";

  # Symlink ~/.config/nvim straight at the repo working tree rather than at the
  # nix store. `vim.pack` writes 'nvim-pack-lock.json' next to init.lua whenever
  # a plugin is added, updated or removed — a store path is read-only, so that
  # write fails with EROFS and takes the whole config down with it.
  #
  # Out-of-store means edits to nvim/ also apply on the next `nvim` start with
  # no `rebuild`, and lockfile changes show up directly in `git status`.
  # Requires this repo to live at the path below.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-config/nvim";
}
