{ pkgs, lib, ... }:
let
  # tetrio-plus (https://gitlab.com/UniQMG/tetrio-plus) is a third-party mod
  # that replaces the client's `app.asar` and adds a customisation panel:
  # custom skins/backgrounds/sound packs, extra HUD readouts, replay tools.
  # It is cosmetic-only — it does not change game rules or talk to the server
  # differently — but it *is* a patched client, so it is a toggle rather than
  # just baked in. The asar is built from source (a yarn build, with no binary
  # cache), so flipping this costs a couple of minutes on the next rebuild;
  # set it back to false to get the stock client from the cache instead.
  withTetrioPlus = true;

  # Run the Electron client on Wayland natively instead of through Xwayland.
  #
  # Xwayland exposes ONE X screen spanning the whole sway layout, and
  # fullscreen X11 clients place themselves at that screen's origin — so on a
  # two-output host a fullscreened game lands offset from where sway draws it
  # and mouse clicks miss the window. That is the bug `Mod+g` game mode in
  # 'sway.nix' exists to work around. Native Wayland clients are positioned by
  # sway itself, so fullscreen is correct per-output and game mode is not
  # needed just to click the menus. Verified: the window maps as `xdg_shell`
  # with `app_id=tetrio-desktop` (not Xwayland), and renders.
  #
  # The upstream wrapper already gates its `--ozone-platform-hint=auto` flags
  # on NIXOS_OZONE_WL being set (this config does not set it globally, so as
  # not to move Chrome/Slack/Obsidian at the same time), hence setting it for
  # this one package. It is a `--set-default`, so a one-off
  # `NIXOS_OZONE_WL= tetrio` still forces the Xwayland path for comparison.
  nativeWayland = true;

  # Pin Electron's EGL to Mesa — REQUIRED on lenovo-yoga, do not drop.
  #
  # libglvnd picks an EGL vendor by filename order, so with the proprietary
  # NVIDIA driver loaded `10_nvidia.json` wins over `50_mesa.json` and Electron
  # runs its GPU process against NVIDIA's libEGL. But sway composites on the
  # Intel iGPU (WLR_DRM_DEVICES in the host file), so every window buffer is an
  # i915 dmabuf that NVIDIA's EGL cannot import: `eglCreateImage failed`,
  # "Unable to initialize binding from pixmap", then GL context loss in a tight
  # retry loop. The game never draws a frame and spams ~30k errors in 20
  # seconds — that is the "won't start" symptom, and it hits the Xwayland path
  # identically, so it is NOT the nativeWayland toggle above.
  #
  # Same root cause family as the gamescope dead end noted in the lenovo-yoga
  # host file: cross-GPU buffer sharing does not work on this hybrid. Forcing
  # the display GPU's own EGL fixes it outright (0 errors). Harmless on hosts
  # with no NVIDIA vendor file, where Mesa is what glvnd would have chosen
  # anyway, so it stays unconditional rather than host-gated.
  mesaEgl = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json";
in
{
  home.packages = [
    ((pkgs.tetrio-desktop.override { inherit withTetrioPlus; }).overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/tetrio \
          --set-default __EGL_VENDOR_LIBRARY_FILENAMES ${mesaEgl} \
          ${lib.optionalString nativeWayland "--set-default NIXOS_OZONE_WL 1"}
      '';
    }))
  ];
}
