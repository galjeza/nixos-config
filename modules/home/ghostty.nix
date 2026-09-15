{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "IosevkaTerm Nerd Font Mono";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Moonfly";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
