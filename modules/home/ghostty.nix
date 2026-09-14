{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "Terminess Nerd Font Mono";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Vague";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
