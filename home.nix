{ config, pkgs, ... }:
{
  # this must match your username
  home.username = "galjeza";
  home.homeDirectory = "/home/galjeza";

  # this must match system.stateVersion in configuration.nix
  home.stateVersion = "25.11";

  # let home-manager manage itself
  programs.home-manager.enable = true;

  programs.bash.enable = true;

  programs.git = {
      enable = true;
      userName = "Gal Jeza";
      userEmail = "gal.jeza55@gmail.com";
  };


 

  # user-specific packages (things only you need, not system-wide)
  home.packages = with pkgs; [
	neovim
	fastfetch
	firefox
	zellij
	alacritty
	waybar
	wofi
	wdisplays
  ];

  home.shellAliases = {
	  rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
  };
}
