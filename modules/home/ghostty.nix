{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Same font as foot (see foot.nix).
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Moonfly";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
