{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/*.tar.gz";

    home-manager = {
      url = "https://flakehub.com/f/nix-community/home-manager/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-generators, home-manager, ... } @attrs:
    let
      # helpers for producing system-specific outputs
      supportedSystems = [
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-linux"
      ];
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forEachSupportedSystem ({ pkgs, ... }: {
        default = nixos-generators.nixosGenerate {
          inherit (pkgs) system;
          specialArgs = attrs;
          format = "install-iso";
          modules = [ ./iso.nix ];
        };
      });
    };
}
