{ ... }:
# Single source of truth for colours.
#
# Everything that paints chrome — sway, swaylock, wmenu, mako, the sway bar and
# the zsh prompt — reads `theme.colors` from here, so re-theming the desktop is
# the one-line `active` change below rather than a sweep through six files.
#
# Hex values are stored WITHOUT a leading '#': swaylock and wmenu take bare hex
# on the command line, while sway/mako want '#rrggbb'. Consumers prefix with
# "#${...}" where they need it.
#
# The one thing that does not follow `active` wholesale is zellij: its theme
# blocks are upstream KDL verbatim (per-widget emphasis colours that don't
# derive from a 7-colour palette), so it reads only the theme *name* from here
# and needs a matching block of its own.
let
  palettes = {
    # vague — https://github.com/vague-theme/vague.nvim
    vague = {
      bg = "141415";
      surface = "252530";
      fg = "cdcdcd";
      muted = "606079";
      blue = "6e94b2";
      gold = "f3be7c";
      red = "d8647e";
      green = "7fa563";

      terminal = {
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
    };

    # moonfly — https://github.com/bluz71/vim-moonfly-colors
    moonfly = {
      bg = "080808";
      surface = "323437";
      fg = "bdbdbd";
      muted = "949494";
      blue = "80a0ff";
      gold = "e3c78a";
      red = "ff5d5d";
      green = "8cc85f";

      terminal = {
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
    };
  };

  # ── The one switch ──────────────────────────────────────────────────────────
  # "vague" | "moonfly"
  active = "moonfly";
in
{
  # Exposed to every other home-manager module as the `theme` argument.
  _module.args.theme = {
    name = active;
    colors = palettes.${active};
    inherit palettes;
  };
}
