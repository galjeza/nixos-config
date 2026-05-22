{ config, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true; # sets $EDITOR to nvim
    viAlias = true; # lets you type 'vi' to open nvim
    vimAlias = true; # lets you type 'vim' to open nvim
    withRuby = false;
    withPython3 = false;
  };

  # symlink /etc/nixos/nvim into ~/.config/nvim
  # so your existing init.lua and lazy.nvim config is picked up by nvim
  xdg.configFile."nvim" = {
    source = ../../nvim; # points to /etc/nixos/nvim
    recursive = true; # symlink each file individually instead of the whole folder
  };
}
