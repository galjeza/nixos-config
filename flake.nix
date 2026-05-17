{
  description = "NixOS configuration";

  # inputs are external dependencies - like package.json in Node.js
  inputs = {
    # the main package repository - pinned to 25.11 stable
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # tell home-manager to use the same nixpkgs as above
      # instead of downloading its own copy
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  # outputs is what this flake produces - in our case a NixOS system
  outputs =
    {
      nixpkgs,
      home-manager,
      neovim-nightly-overlay,
      ...
    }:
    let
      # shared home-manager config used by all machines
      homeManagerModule = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.galjeza = import ./modules/home/default.nix;
        home-manager.backupFileExtension = "bak";
      };

      neovimNightlyModule = {
        nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];
      };
    in
    {
      nixosConfigurations = {

        lenovo-yoga = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/lenovo-yoga/configuration.nix # your main system config
            neovimNightlyModule
            home-manager.nixosModules.home-manager
            homeManagerModule
          ];
        };

        nixos-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nixos-vm/configuration.nix # your main system config
            neovimNightlyModule
            home-manager.nixosModules.home-manager
            homeManagerModule
          ];
        };

        arch-nixos-vm = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/arch-nixos-vm/configuration.nix # your main system config
            neovimNightlyModule
            home-manager.nixosModules.home-manager
            homeManagerModule
          ];
        };
      };
    };
}
