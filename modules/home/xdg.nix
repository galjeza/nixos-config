{ ... }:
let
  # Chrome is the default browser everywhere — see google-chrome in default.nix.
  browser = [ "google-chrome.desktop" ];
in
{
  home.sessionVariables = {
    BROWSER = "google-chrome-stable";
    DEFAULT_BROWSER = "google-chrome-stable";
  };

  # Declarative ~/.config/mimeapps.list. This replaces the imperative file that
  # `xdg-mime default` / "make me the default browser" prompts used to write, so
  # every handler we care about has to be listed here.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # web pages + the URL schemes anything hands to xdg-open
      "text/html" = browser;
      "application/xhtml+xml" = browser;
      "application/x-extension-htm" = browser;
      "application/x-extension-html" = browser;
      "application/x-extension-shtml" = browser;
      "application/x-extension-xhtml" = browser;
      "application/x-extension-xht" = browser;
      "x-scheme-handler/http" = browser;
      "x-scheme-handler/https" = browser;
      "x-scheme-handler/about" = browser;
      "x-scheme-handler/unknown" = browser;
      "x-scheme-handler/chrome" = browser;

      # non-browser handlers, carried over from the old imperative mimeapps.list
      "x-scheme-handler/claude-cli" = [ "claude-code-url-handler.desktop" ];
      "x-scheme-handler/tg" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/tonsite" = [ "org.telegram.desktop.desktop" ];
      "x-scheme-handler/slack" = [ "slack.desktop" ];
      "x-scheme-handler/discord-409416265891971072" = [ "discord-409416265891971072.desktop" ];

      # svg is an image, not a web page — keep it in loupe rather than letting it
      # fall through to the browser now that this file is exhaustive
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
    };
  };
}
