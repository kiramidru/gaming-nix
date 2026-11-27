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

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg:
              pkg.name == "project_zomboid_42_20_2_92872.sh";
          };

          packages = {
            balatro = pkgs.callPackage ./modules/balatro { };
            broforce = pkgs.callPackage ./modules/broforce { };
            celeste = pkgs.callPackage ./modules/celeste { };
            crawl = pkgs.callPackage ./modules/crawl { };
            cuphead = pkgs.callPackage ./modules/cuphead { };
            devil-daggers = pkgs.callPackage ./modules/devil-daggers { };
            fury-unleashed = pkgs.callPackage ./modules/fury-unleashed { };
            gris = pkgs.callPackage ./modules/gris { };
            halo-ce = pkgs.callPackage ./modules/halo-ce { };
            libreaim = pkgs.callPackage ./modules/libreaim { };
            minecraft-launcher = pkgs.callPackage ./modules/minecraft-launcher { };
            project-zomboid = pkgs.callPackage ./modules/project-zomboid { };
            slay-the-princess = pkgs.callPackage ./modules/slay-the-princess { };
            tmnt-shredders-revenge = pkgs.callPackage ./modules/tmnt-shredders-revenge { };
          };
        };
    };
}
