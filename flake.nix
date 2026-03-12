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
  };

  # outputs is what this flake produces - in our case a NixOS system
  outputs = { nixpkgs, home-manager, ... }: {
    # "nixos" here must match your hostname in configuration.nix
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix          # your main system config
        home-manager.nixosModules.home-manager  # plug home-manager into nixos
        {
          # use the same pkgs as the system (no duplicate downloads)
          home-manager.useGlobalPkgs = true;
          # install user packages into the user profile instead of system
          home-manager.useUserPackages = true;
          # point to your personal home-manager config file
          home-manager.users.galjeza = import ./home.nix;
        }
      ];
    };
  };
}

