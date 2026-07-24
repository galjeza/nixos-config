{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Cap battery charge at ~60% via ideapad EC conservation mode.
  systemd.tmpfiles.rules = [
    "w /sys/devices/pci0000:00/0000:00:1f.0/PNP0C09:00/VPC2004:00/conservation_mode - - - - 1"
  ];

  # ── Graphics: Intel iGPU + NVIDIA PRIME ─────────────────────────────────────
  # Intel iGPU drives the display, NVIDIA RTX 4070 stays asleep until a CUDA
  # workload (or an explicit `nvidia-offload <cmd>`) wakes it. The shared
  # `hardware.graphics.enable` lives in common.nix; only the Intel driver bits
  # are host-specific.
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver # VAAPI for Meteor Lake
    vpl-gpu-rt # Intel Quick Sync runtime
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  # Pin Sway/wlroots to the Intel iGPU so it doesn't try to use the NVIDIA
  # card for display. card1 = i915 on this machine (the NVIDIA card at PCI
  # 01:00.0 enumerates as card0). Cannot use the by-path identifier here
  # because WLR_DRM_DEVICES splits on ':' and PCI paths contain colons.
  environment.sessionVariables = {
    WLR_DRM_DEVICES = "/dev/dri/card1";
  };

  # Sway hard-refuses to start when the proprietary NVIDIA driver is loaded;
  # this flag bypasses that check. The iGPU still drives the display via PRIME.
  programs.sway.extraOptions = [ "--unsupported-gpu" ];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Bus IDs verified from /sys: Intel 00:02.0, NVIDIA 01:00.0
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ── Gaming ──────────────────────────────────────────────────────────────────
  programs.steam.enable = true;
  # gamemode: CPU governor + priority tuning for games. Use per-game via
  # Steam launch options: gamemoderun %command%
  # NOTE: gamescope was tried to fix the XWayland mouse-offset ("can't click
  # buttons") issue, but nested gamescope is broken on this Intel+NVIDIA
  # hybrid (cross-GPU swapchain sharing fails, games die on the first frame).
  # Use the game's own Borderless Windowed mode instead — no resolution change
  # means no XWayland pointer offset, and clicks land correctly.
  programs.gamemode.enable = true;

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
