{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  networking.hostName = "lenovo-yoga";

  # Cap battery charge at ~60% via ideapad EC conservation mode.
  systemd.tmpfiles.rules = [
    "w /sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode - - - - 1"
  ];

  # ── Graphics: Intel iGPU; the RTX 4070 only in the "nvidia" boot entry ─────
  # The proprietary driver hard-froze this machine ten times between
  # 2026-08-26 and 2026-10-21, mostly while idle on the lock screen. The
  # firmware sends the card ACPI `Notify(NPCF, 0xC0)` power-budget events, and
  # the driver's handler (`rm_acpi_nvpcf_notify`) page-faults on the
  # kacpi_notify workqueue with IRQs off. The panel keeps its last frame lit,
  # keys and a power-button tap do nothing because the kernel is gone, and on
  # 10-21 not even a 10 s hold cut the power: it sat there until the battery
  # was flat. Newer drivers and kernels didn't fix it, and no module parameter
  # turns the handler off (NVIDIA forum t/385856, open-gpu-kernel-modules#860).
  #
  # So the default boot never loads the driver and takes the card off the PCI
  # bus. The desktop loses nothing: eDP-1 and HDMI-A-1 both hang off the Intel
  # card, and the NVIDIA card's only connector (eDP-2) is never connected.
  # For games, pick "nvidia" in the boot menu. That entry brings PRIME offload
  # back, and the freeze risk with it, so use it only for gaming sessions.
  #
  # The shared `hardware.graphics.enable` lives in common.nix; only the Intel
  # driver bits are host-specific.
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # VAAPI for Meteor Lake
    vpl-gpu-rt # Intel Quick Sync runtime
  ];

  # Inert in the default boot: the whole nvidia module sits behind
  # `hardware.nvidia.enabled`, which only the "nvidia" entry turns on. It lives
  # out here so `enableOffloadCmd` reads true in both boots, and common.nix
  # stamps `nvidia-offload` into Steam launch options whichever one Steam
  # first sees a game in.
  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    # Bus IDs verified from /sys: Intel 00:02.0, NVIDIA 01:00.0
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  # Default boot: remove the card from the PCI bus as soon as udev sees it, so
  # nothing can bind to it and its root port is free to drop it into D3cold. A
  # driverless card left on the bus sits in D0 and keeps the port awake. The
  # blacklist covers a later PCI rescan bringing it back.
  boot.blacklistedKernelModules = lib.mkIf (!config.hardware.nvidia.enabled) [
    "nouveau"
    "nova_core"
    "nvidiafb"
  ];
  services.udev.extraRules = lib.mkIf (!config.hardware.nvidia.enabled) ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  # Steam launch options already say `nvidia-offload gamemoderun %command%`.
  # Without the driver, the command still has to exist; the game simply runs
  # on the Intel GPU.
  environment.systemPackages = lib.mkIf (!config.hardware.nvidia.enabled) [
    (pkgs.writeShellScriptBin "nvidia-offload" ''exec "$@"'')
  ];

  specialisation.nvidia.configuration = {
    system.nixos.tags = [ "nvidia" ];

    services.xserver.videoDrivers = [ "nvidia" ];

    # Pin Sway/wlroots to the Intel iGPU so it doesn't try to use the NVIDIA
    # card for display. With the driver loaded, card1 = i915 (the NVIDIA card
    # at PCI 01:00.0 enumerates as card0). In the default boot there is only
    # one card, so nothing is pinned there. Cannot use the by-path identifier
    # because WLR_DRM_DEVICES splits on ':' and PCI paths contain colons.
    environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/card1";

    # Sway hard-refuses to start when the proprietary NVIDIA driver is loaded;
    # this flag bypasses that check. The iGPU still drives the display via PRIME.
    programs.sway.extraOptions = [ "--unsupported-gpu" ];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # powerManagement.enable wraps every suspend in nvidia-sleep.sh, which does
    # `chvt 63` before sleeping and switches back on resume so an X server on
    # the NVIDIA card lets go of it. Nothing here displays on that card (sway
    # is pinned to the iGPU above), so all the round-trip does is make sway
    # drop and re-take its VT, DRM master and every input device while
    # swaylock holds the lock. It is the prime suspect for the "dead lock
    # screen" resumes — dark screen, keys do nothing, power button the only way
    # out — which began with the move to greetd (sway on VT1, 2026-09-15): none
    # in the month before, near-daily after. Keep the driver notification (it
    # is what saves VRAM under PreserveVideoMemoryAllocations), drop the VT
    # switch.
    systemd.services =
      let
        nvidiaSleep =
          state:
          lib.mkForce (
            pkgs.writeShellScript "nvidia-${state}" ''
              [ -e /proc/driver/nvidia/suspend ] || exit 0
              echo ${state} > /proc/driver/nvidia/suspend
            ''
          );
      in
      {
        nvidia-suspend.serviceConfig.ExecStart = nvidiaSleep "suspend";
        nvidia-resume.serviceConfig.ExecStart = nvidiaSleep "resume";
      };
  };

  # ── Gaming ──────────────────────────────────────────────────────────────────
  # Steam + gamemode are in common.nix.
  #
  # NOTE: gamescope was tried to fix the XWayland mouse-offset ("can't click
  # buttons") issue, but nested gamescope is broken on this Intel+NVIDIA
  # hybrid (cross-GPU swapchain sharing fails, games die on the first frame).
  # Use the game's own Borderless Windowed mode instead — no resolution change
  # means no XWayland pointer offset, and clicks land correctly.

  # ── Waydroid: Android container (for Boom Beach etc.) ───────────────────────
  # Runs a full Android userspace in an LXC container on the host kernel via
  # binder. Needs Wayland (Sway provides it). After a rebuild, run once:
  #   sudo waydroid init -s GAPPS      # download image WITH Google Play
  #   sudo systemctl start waydroid-container
  #   waydroid session start &         # then: waydroid show-full-ui
  # See the notes at the bottom of this section for getting Boom Beach on.
  virtualisation.waydroid = {
    enable = true;

    # This kernel ships ONLY the nftables netfilter backend — the legacy
    # ip_tables.ko modules don't exist. Waydroid's default waydroid-net.sh
    # hard-prefers the `iptables-legacy` binary, so the container's network
    # setup dies with "can't initialize iptables table `filter'". The package's
    # `withNftables` flag builds the script to drive `nft` directly (and puts
    # it on the script's PATH), which works with the nft_tables module we do
    # have.
    package = pkgs.waydroid.override { withNftables = true; };
  };

  # Boom Beach is online-only, so the container must reach the internet. The
  # NixOS firewall would otherwise drop forwarded traffic on Waydroid's bridge.
  networking.firewall.trustedInterfaces = [ "waydroid0" ];

  # ── Audio: Yoga Pro 9 16IMH9 speaker workaround ─────────────────────────────
  # Force the ALC287 fixup that wires the TAS2781 i2c amps as speaker output.
  # The kernel doesn't have a quirk for PCI SSID 17aa:3811, so we hint the
  # model explicitly.
  boot.extraModprobeConfig = ''
    options snd-hda-intel model=yoga9-bass-spk-pin
  '';

  # ── Laptop: lid switch + bluetooth ──────────────────────────────────────────
  # Lid close → suspend. Docked (external monitor connected) → ignore so the
  # machine stays up. swayidle still locks before sleep via the before-sleep hook.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Bluetooth + Blueman GUI (blueman-manager for pairing, blueman-applet tray)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true; # battery % reporting for some devices
  };
  services.blueman.enable = true;
}
