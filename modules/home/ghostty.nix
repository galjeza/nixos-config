{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # JetBrainsMono Nerd Font — installed via home.packages (nerd-fonts.jetbrains-mono).
      font-family = "JetBrainsMono Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Moonfly";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
