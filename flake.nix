{
  description = "Caddy with Cloudflare plugin and expanded module";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixos-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];

    perSystem = attrs:
      nixpkgs.lib.genAttrs supportedSystems (system:
        attrs (import nixpkgs {inherit system;}));
  in {
    # nix build
    packages = perSystem (system: pkgs: {
      caddy = pkgs.buildGoModule {
        pname = "caddy";
        inherit version;
        src = ./caddy-src;
        runVend = true;
        vendorHash = "sha256-P5j2Lo5QZdxFyHdfUIozwlxDZ4PiwT/fOwn7f4MZPFQ=";
      };
      default = self.packages.${system}.caddy;
    });

    # Default module
    nixosModules.default = import ./modules inputs;

    # nix develop
    devShells = perSystem (_: pkgs: {
      default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          go
        ];
      };
    });
  };
}
