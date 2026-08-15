{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "shovel-knight";
      version = "4.1";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        libGL
        libx11
        libxext
        libxrandr
        alsa-lib
        libpulseaudio
        gtk2
        glib
        cairo
        pango
        gdk-pixbuf
        udev
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "shovel-knight";
        desktopName = "Shovel Knight";
        exec = "shovel-knight";
        icon = "shovel-knight";
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
          url = "https://archive.org/download/shovel-knight-treasure-trove-linux-gog-phoenix-games-lab/shovel_knight_treasure_trove_4_1b_arby_s_46298.sh";
          hash = "sha256-wUvGamTa7MWuDPhfhfpdc91zca1wp/scyFDATZ3PiAo=";
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

          makeWrapper $out/opt/${pname}/64/ShovelKnight $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps} \
            --chdir $out/opt/${pname}

          runHook postInstall
        '';

        dontStrip = true;
      };
    };
}
