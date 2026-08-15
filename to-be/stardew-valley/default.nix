{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "stardew-valley";
      version = "1.6.15";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        libGL
        libglvnd
        libx11
        libxi
        libxcursor
        libxrandr
        libxkbcommon
        alsa-lib
        libpulseaudio
        udev
        zlib
        openal
        SDL2
        lttng-ust
        fontconfig
        libxft
        libcap
        icu
        openssl
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "stardew-valley";
        desktopName = "Stardew Valley";
        exec = "stardew-valley";
        icon = "stardew-valley";
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
          url = "https://archive.org/download/stardew-valley-linux-gog-phoenix-games-lab/stardew_valley_1_6_15_24357_8705766150_78675.sh";
          sha256 = "sha256-mq50ltEZKJ8WF9apw9dJ83zTLNE+NNMgAVq8LBtVcO8=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          unzip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        autoPatchelfIgnoreMissingDeps = [ "liblttng-ust.so.0" ];

        unpackPhase = "unzip -q $src -d source || true";

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r source/data/noarch/game/* $out/opt/${pname}

          makeWrapper $out/opt/${pname}/StardewValley $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
