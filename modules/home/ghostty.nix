{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      # IoskeleyMono — installed via home.packages (ioskeley-mono.normal-term-NF).
      # The "Term" build is the one upstream recommends for terminals.
      # font-family = "JetBrainsMono Nerd Font";
      font-family = "IoskeleyMonoTerm Nerd Font";
      font-size = 11;

      # Built-in theme shipped with ghostty. List others with `ghostty +list-themes`.
      theme = "Vague";

      # Close windows/tabs/splits immediately, without the confirmation prompt.
      confirm-close-surface = false;
    };
  };
}
