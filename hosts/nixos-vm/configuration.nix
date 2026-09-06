{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos-vm";

  # SPICE guest agent: clipboard sharing + dynamic resolution with the host.
  services.spice-vdagentd.enable = true;
}
