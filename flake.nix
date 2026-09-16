{
  description = "NixOS configuration";

  # inputs are external dependencies - like package.json in Node.js
  inputs = {
    # main package repository (rolling)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      # rolling home-manager to match nixpkgs
      url = "github:nix-community/home-manager";
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
      system = "x86_64-linux";

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

      # Every host is the same recipe: its own 'hosts/<name>/configuration.nix'
      # (which pulls in that host's hardware config + modules/system/common.nix)
      # plus the three shared modules above. `networking.hostName` is set inside
      # each host file and MUST equal the attr name here — the `rebuild` aliases
      # rely on nixos-rebuild resolving nixosConfigurations.<hostname> itself.
      mkHost =
        name:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/${name}/configuration.nix
            neovimNightlyModule
            home-manager.nixosModules.home-manager
            homeManagerModule
          ];
        };

      hosts = [
        "lenovo-yoga"
        "desktop"
      ];
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts mkHost;

      # `nix fmt` formats the whole tree. nixfmt-tree is the treefmt wrapper
      # around nixfmt (the RFC-166 formatter, formerly `nixfmt-rfc-style`) —
      # `nix fmt` hands its formatter a directory, which bare nixfmt has
      # deprecated, and the wrapper is what handles that properly.
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
