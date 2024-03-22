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
      caddy = pkgs.buildGo120Module {
        pname = "caddy";
        inherit version;
        src = ./caddy-src;
        runVend = true;
        vendorHash = "sha256-CvyQQNzdWn10AH9ekCVdbgQbYSv06ICl3Q9VYngT3Q4=";
      };
      default = self.packages.${system}.caddy;
    });

    nixosModules = {
      caddy = import ./modules self nixpkgs;

      default = self.nixosModules.caddy;
    };

    formatter = perSystem (pkgs: pkgs.alejandra);

    devShells = perSystem (pkgs: {
      update = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          bash
          common-updater-scripts
          git
          go
          jq
          nix-prefetch-git
          nix-prefetch-github
          nix-prefetch-scripts
        ];
      };
    });
  };
}
