{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";

  # ── Graphics: AMD Radeon (Navi 33, RX 7600 XT) ──────────────────────────────
  # Mesa (RADV + radeonsi) comes from the shared `hardware.graphics.enable` in
  # common.nix and needs no extra driver packages — do NOT add amdvlk, it
  # shadows RADV and is slower. This only pulls amdgpu into the initrd so the
  # card owns the console from the start instead of handing over from
  # simpledrm partway through boot (avoids the mode flicker at handover).
  hardware.amdgpu.initrd.enable = true;

  # ── Gaming ──────────────────────────────────────────────────────────────────
  # Unlike the yoga there is no hybrid-GPU offload and no second output here,
  # so none of the laptop's PRIME / XWayland-origin workarounds apply — the
  # single Radeon drives everything and the ultrawide already owns (0,0).
  programs.steam.enable = true;
  # gamemode: CPU governor + priority tuning. Use per-game via Steam launch
  # options: gamemoderun %command%
  programs.gamemode.enable = true;

  # ── Wi-Fi: Realtek RTL8852CE (rtw89) ────────────────────────────────────────
  # This is a *combo* Wi-Fi 6E + Bluetooth chip: both radios share the same
  # antenna path, and rtw89's BT-coexistence arbiter hands airtime to BT
  # whenever the BT side is live. This box has no use for Bluetooth, so the BT
  # function is kept unbound entirely — bluez off AND btusb blacklisted, so
  # the radio never initialises and coexistence never kicks in. (Leaving
  # `hardware.bluetooth.enable = false` alone is not enough: btusb still binds
  # the USB BT function and powers the radio.)
  hardware.bluetooth.enable = false;
  boot.blacklistedKernelModules = [ "btusb" ];

  boot.extraModprobeConfig = ''
    # rtw89 defaults to PCIe ASPM L1 + clock-request power saving, which on
    # AMD platforms causes throughput collapse and latency spikes. Irrelevant
    # power cost on a desktop.
    options rtw89_pci disable_aspm_l1=1 disable_aspm_l1ss=1 disable_clkreq=1
    # Wi-Fi power-save mode adds latency and stalls throughput on this driver.
    options rtw89_core disable_ps_mode=1
  '';

  # NetworkManager applies its own power saving on top of the driver's.
  networking.networkmanager.wifi.powersave = false;
}
