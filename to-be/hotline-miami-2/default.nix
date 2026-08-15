{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "hotline-miami-2";
      version = "2.0.0";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        glibc
        libGL
        libGLU
        nvidia_cg_toolkit
        libx11
        openal
        libvorbis
        libogg
        SDL2
        fontconfig
        freetype
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "hotline-miami-2";
        desktopName = "Hotline Miami 2";
        exec = "hotline-miami-2";
        icon = "hotline-miami-2";
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
          url = "https://archive.org/download/hotline-miami-2-wrong-number-linux-gog-phoenix-games-lab/hotline_miami_2_wrong_number_en_07_12_2017_16977.sh";
          sha256 = "sha256-UsQZXX7Umow9vhMck1m2s1Lxk7CqGHMV2xiGo0Vds5s=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          unzip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        unpackPhase = "unzip -q $src -d source || true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/data/noarch/game/* $out/opt/${pname}

          makeWrapper $out/opt/${pname}/HotlineMiami2 $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
