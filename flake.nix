{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixos-generators, ... }:
    let
      # helpers for producing system-specific outputs
      supportedSystems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        inherit system;
      });
    in
    {
      packages = forEachSupportedSystem ({ pkgs, system, ... }: {
        default = nixos-generators.nixosGenerate {
          inherit system;
          format = "install-iso";

          modules = [ ./iso.nix ];
        };
      });
    };
}
