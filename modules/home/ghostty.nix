{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Same font as foot (see foot.nix).
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty (classic Solarized Dark).
      # List others with `ghostty +list-themes`.
      theme = "Solarized Dark Patched";
    };
  };
}
