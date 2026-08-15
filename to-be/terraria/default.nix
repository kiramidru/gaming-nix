{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "terraria";
      version = "1.4.5.6";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        libGLU
        gtk2
        gtk3
        cairo
        pango
        fna3d
        faudio
        vulkan-loader
        sdl3
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "terraria";
        desktopName = "Terraria";
        exec = "terraria";
        icon = "terraria";
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
          url = "https://archive.org/download/terraria-linux-gog/terraria_v1_4_5_6_89299.sh";
          sha256 = "sha256-/Zcig13dC3atCjGjfw3kKe3EmkxM4Hc3cCFuqZT5BvU=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          unzip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        autoPatchelfIgnoreMissingDeps = [
          "libGLES_CM.so.1"
          "libsteam_api.so"
        ];

        unpackPhase = "unzip -q $src -d source || true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/data/noarch/game/* $out/opt/${pname}

          makeWrapper $out/opt/${pname}/Terraria.bin.x86_64 $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
