{
  description = "Nix Collection of Programs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./modules/balatro
        ./modules/blender
        ./modules/broforce
        ./modules/celeste
        ./modules/duck-detective
        ./modules/hotline-miami
        ./modules/hotline-miami-2
        ./modules/jedi-academy
        ./modules/shovel-knight
        ./modules/stardew-valley
        ./modules/terraria
        ./modules/undertale
        ./modules/until-then
      ];
    };
}
