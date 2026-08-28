{ config, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets $EDITOR to nvim
    viAlias = true; # lets you type 'vi' to open nvim
    vimAlias = true; # lets you type 'vim' to open nvim
    withRuby = false;
    withPython3 = false;
  };

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
