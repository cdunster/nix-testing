{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs: {
    nixosConfigurations.test-vm = inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixos/configuration.nix
      ];
    };
  } // inputs.flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${system}.appendOverlays [
        inputs.rust-overlay.overlays.default
      ];
      rustFromFile = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
    in
    {
      apps.test-vm = {
        type = "app";
        program = "${self.nixosConfigurations.test-vm.config.system.build.vm}/bin/run-nixos-vm";
      };

      devShells.default = pkgs.mkShell {
        packages = [
          rustFromFile
        ];

        RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
      };

      packages.default = pkgs.rustPlatform.buildRustPackage {
        pname = "test-scenario";
        version = "0.1.0";
        src = ./.;
        cargoLock = {
          lockFile = ./Cargo.lock;
        };
      };
    });
}
