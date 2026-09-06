{config,pkgs,...}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/common.nix
  ];

  networking.hostName = "nixos";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
}
