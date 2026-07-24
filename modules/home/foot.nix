{ ... }:
let
  # Terminal (foot) theme. Change this value and `rebuild` to switch.
  # Palettes are defined below; add more the same way.
  footTheme = "rose-pine-dawn"; # "vague" | "moonfly" | "rose-pine-dawn"

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

    # rose-pine-dawn (light) — https://github.com/rose-pine/rose-pine-theme
    rose-pine-dawn = {
      background = "faf4ed";
      foreground = "575279";

      regular0 = "f2e9e1"; # overlay
      regular1 = "b4637a"; # love
      regular2 = "286983"; # pine
      regular3 = "ea9d34"; # gold
      regular4 = "56949f"; # foam
      regular5 = "907aa9"; # iris
      regular6 = "d7827e"; # rose
      regular7 = "575279"; # text

      bright0 = "9893a5"; # muted
      bright1 = "b4637a";
      bright2 = "286983";
      bright3 = "ea9d34";
      bright4 = "56949f";
      bright5 = "907aa9";
      bright6 = "d7827e";
      bright7 = "575279";

      cursor = "faf4ed 575279";
      selection-background = "dfdad9";
      selection-foreground = "575279";
    };
  };
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=11";
      };
      # Palette selected by `footTheme` above.
      colors-dark = footPalettes.${footTheme};
    };
  };
}
