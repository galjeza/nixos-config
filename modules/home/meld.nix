{ pkgs, ... }:
{
  home.packages = [ pkgs.meld ];

  dconf.settings = {
    "org/gnome/meld" = {
      highlight-syntax = true;
      show-line-numbers = true;
      highlight-current-line = true;
      wrap-mode = 0;
    };
  };
}
