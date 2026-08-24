{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Iosevka Nerd Font — installed via home.packages (nerd-fonts.iosevka).
      font-family = "Iosevka Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Moonfly";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
