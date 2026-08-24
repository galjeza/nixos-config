{ ... }:
let
  # Terminal (foot) theme. Change this value and `rebuild` to switch.
  # Palettes are defined below; add more the same way.
  footTheme = "solarized-light"; # "vague" | "moonfly" | "solarized-light"

  footPalettes = {
    # vague — https://github.com/vague-theme/vague.nvim
    vague = {
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

    # moonfly — https://github.com/bluz71/vim-moonfly-colors
    moonfly = {
      background = "080808";
      foreground = "bdbdbd";

      regular0 = "323437";
      regular1 = "ff5d5d";
      regular2 = "8cc85f";
      regular3 = "e3c78a";
      regular4 = "80a0ff";
      regular5 = "cf87e8";
      regular6 = "79dac8";
      regular7 = "c6c6c6";

      bright0 = "949494";
      bright1 = "ff5189";
      bright2 = "36c692";
      bright3 = "c6c684";
      bright4 = "74b2ff";
      bright5 = "ae81ff";
      bright6 = "85dc85";
      bright7 = "e4e4e4";

      cursor = "080808 9e9e9e";
      selection-background = "b2ceee";
      selection-foreground = "080808";
    };

    # solarized-light — https://github.com/altercation/solarized
    solarized-light = {
      background = "fdf6e3"; # base3
      foreground = "657b83"; # base00

      regular0 = "073642"; # base02
      regular1 = "dc322f"; # red
      regular2 = "859900"; # green
      regular3 = "b58900"; # yellow
      regular4 = "268bd2"; # blue
      regular5 = "d33682"; # magenta
      regular6 = "2aa198"; # cyan
      regular7 = "eee8d5"; # base2

      bright0 = "002b36"; # base03
      bright1 = "cb4b16"; # orange
      bright2 = "586e75"; # base01
      bright3 = "657b83"; # base00
      bright4 = "839496"; # base0
      bright5 = "6c71c4"; # violet
      bright6 = "93a1a1"; # base1
      bright7 = "fdf6e3"; # base3

      cursor = "fdf6e3 657b83";
      selection-background = "eee8d5";
      selection-foreground = "586e75";
    };
  };
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "Iosevka Nerd Font:size=11";
      };
      # Palette selected by `footTheme` above.
      colors-dark = footPalettes.${footTheme};
    };
  };
}
