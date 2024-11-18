{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, ... }@inputs: inputs.flake-utils.lib.eachDefaultSystem (system:
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
      };

      packages = {
        default = pkgs.rustPlatform.buildRustPackage {
          pname = "test-scenario";
          version = "0.1.0";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
          };
        };

        run-on-rpi =
          let
            target = "user@192.168.178.31";
          in
          pkgs.writeShellApplication {
            name = "run-on-rpi";
            text = ''
              echo "copy to RPi"
              nix copy --to ssh://${target} ${self.packages.aarch64-linux.default}

              echo "running on RPi"
              ssh ${target} ${self.packages.aarch64-linux.default}/bin/test-scenario
            '';
          };
      };
    });
}
