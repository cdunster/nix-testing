{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { ... }@inputs: {
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
      devShells.default = pkgs.mkShell {
        packages = [
          rustFromFile
        ];

        RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
        QEMU_NET_OPTS = "hostfwd=tcp::2221-:22"; # Forward VM SSH port to host port 2221
      };
    });
}
