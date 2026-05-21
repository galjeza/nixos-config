{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user.name = "Gal Jeza";
      user.email = "gal.jeza55@gmail.com";
      merge.tool = "meld";
    };
  };
}
