{ theme, ... }:
# The terminal — `terminal` in 'sway.nix', so Mod+Return opens it. Colours and
# font both come from 'theme.nix'.
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.font}:size=11";
      };
      colors-dark = theme.colors.terminal;
    };
  };
}
