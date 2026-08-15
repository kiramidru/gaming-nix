{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "jedi-academy";
      version = "1.4.0";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        libjpeg8
        libpng
        libGL
        SDL2
        zlib
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "star-wars-jedi-academy";
        desktopName = "Star Wars: Jedi Academy";
        exec = "jedi-academy";
        icon = "jedi-academy";
        terminal = false;
        categories = [
          "Game"
        ];
      };
    in
    {
      packages.${pname} = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://github.com/JACoders/OpenJK/releases/download/latest/OpenJK-linux-x86_64.tar.gz";
          sha256 = "sha256-1DWJuKzTiaQYtHH8/ADZG+SUBV0xm7cD6yFBnggsYIY=";
        };

        game = pkgs.fetchzip {
          url = "https://archive.org/download/jedi-academy.tar/JediAcademy.tar.gz";
          sha256 = "sha256-/tGT+mIhZZ8pHmvOK1XhunyD+ozoNcSg/Vh8ucHJLm0=";
        };

        sourceRoot = ".";

        nativeBuildInputs = with pkgs; [
          makeWrapper
          autoPatchelfHook
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        installPhase = ''
          mkdir -p $out/bin $out/opt/${pname}

          cp -r . $out/opt/${pname}
          cp -r $game/GameData/GameData/base/* $out/opt/${pname}/base
                    
          makeWrapper $out/opt/${pname}/openjk.x86_64 $out/bin/${pname} \
            --add-flags "+set fs_basepath $out/opt/${pname}" \
            --add-flags "+set com_maxfps 120" \
            --add-flags "+set r_customwidth 1920" \
            --add-flags "+set r_customheight 1080" \
            --add-flags "+set r_mode -1" \
            --add-flags "+set r_fullscreen 1"
        '';

        dontStrip = true;
      };
    };
}
