{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pkgs32 = pkgs.pkgsi686Linux;
      pname = "hotline-miami";
      version = "2.0.0";

      deps = with pkgs32; [
        stdenv.cc.cc.lib
        libGL
        libGLU
        nvidia_cg_toolkit
        libX11
        openal
        libvorbis
        libogg
        SDL2
        fontconfig
        freetype
        zlib
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "hotline-miami";
        desktopName = "Hotline Miami";
        exec = "hotline-miami";
        icon = "hotline-miami";
        terminal = false;
        categories = [
          "Game"
        ];
      };
    in
    {
      packages.${pname} = pkgs32.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://archive.org/download/hotline-miami-linux-gog-phoenix-games-lab/gog_hotline_miami_2.0.0.4.sh";
          sha256 = "sha256-UsQZXX7Umow9vhMck1m2s1Lxk7CqGHMV2xiGo0Vds5s=";
        };

        nativeBuildInputs = with pkgs32; [
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

          makeWrapper $out/opt/${pname}/Hotline $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs32.lib.makeLibraryPath deps}

          runHook postInstall
        '';
      };
    };
}
