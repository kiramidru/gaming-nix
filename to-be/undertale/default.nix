{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pkgs32 = pkgs.pkgsi686Linux;
      pname = "undertale";
      version = "1.08";

      deps = with pkgs32; [
        stdenv.cc.cc.lib
        libGL
        libGLU
        libx11
        libxext
        libxrandr
        libXxf86vm
        openal
        zlib
        alsa-lib
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "undertale";
        desktopName = "Undertale";
        exec = "undertale";
        icon = "undertale";
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
          url = "https://archive.org/download/undertale-linux-gog-phoenix-games-lab/game-Undertale_%28v1.08%29_%5BLinux%2C_GOG%2C_Archive%2C_Fixed_Libs%5D.tar.xz";
          sha256 = "sha256-uQVUyDDlfAtXwGdLcQoLU2CGgabI0tOzS8xIGEmMR1M=";
        };

        nativeBuildInputs = with pkgs32; [
          autoPatchelfHook
          makeWrapper
          unzip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        unpackPhase = ''
          mkdir source
          tar -xf "$src" -C source
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/game/* $out/opt/${pname}

          makeWrapper $out/opt/${pname}/runner $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs32.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
