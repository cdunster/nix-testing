{
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  outputs = { ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations.test-vm = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./nixos/configuration.nix
        ];
      };

      devShells.${system}.default = pkgs.mkShell {
        QEMU_NET_OPTS = "hostfwd=tcp::2221-:22"; # Forward VM SSH port to host port 2221
      };
    };
}
