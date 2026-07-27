{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # Ioskeley Mono (Nerd Font) — custom Iosevka build installed via
      # home.packages (see modules/home/default.nix).
      font-family = "IoskeleyMono Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Moonfly";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
