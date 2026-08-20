{
  description = "Nix Collection of Programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      perSystem = { pkgs, ... }: {
        packages = {
          balatro = pkgs.callPackage ./modules/balatro { };
          broforce = pkgs.callPackage ./modules/broforce { };
          celeste = pkgs.callPackage ./modules/celeste { };
          crawl = pkgs.callPackage ./modules/crawl { };
          devil-daggers = pkgs.callPackage ./modules/devil-daggers { };
          gris = pkgs.callPackage ./modules/gris { };
          minecraft = pkgs.callPackage ./modules/minecraft { };
          tmnt-shredders-revenge = pkgs.callPackage ./modules/tmnt-shredders-revenge { };
        };
      };
    };
}
