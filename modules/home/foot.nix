{ theme, ... }:
# Foot is no longer the default terminal (ghostty is) — it stays around as the
# lightweight fallback, so it just follows the global palette from 'theme.nix'.
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "IosevkaTerm Nerd Font Mono:size=11";
      };
      colors-dark = theme.colors.terminal;
    };
  };
}
