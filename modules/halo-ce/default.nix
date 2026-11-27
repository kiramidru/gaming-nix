{ lib, pkgs, ... }:
let
  pname = "halo-ce";
  version = "v0.7.2e";

  deps = with pkgs; [
    sdl3
    libGL
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Halo CE";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  halo-ce = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/ChupathingyCE/chupathingyce/releases/download/${version}/chupathingyce-linux64-release.zip";
      sha256 = "sha256-iji4aE/3UClntwjdQwTeUCcFMW/D0sVzre7U86zrWsQ=";
    };

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.unzip
      pkgs.makeWrapper
      pkgs.copyDesktopItems
    ];

    buildInputs = deps;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt/${pname}" "$out/bin"
      cp -r . "$out/opt/${pname}/"
      chmod +x "$out/opt/${pname}/halo"

      makeWrapper "$out/opt/${pname}/halo" "$out/bin/${pname}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath deps} \
        --run 'export HALO_DATA_ROOT="''${HALO_DATA_ROOT:-''${XDG_DATA_HOME:-$HOME/.local/share}/${pname}}"' \
        --run 'if [ ! -f "$HALO_DATA_ROOT/maps/ui.map" ]; then
          printf "Halo CE requires Xbox game data. Put maps/ui.map and the other maps in %s/maps or set HALO_DATA_ROOT.\n" "$HALO_DATA_ROOT" >&2
          exit 1
        fi
        cd -- "$HALO_DATA_ROOT" || exit 1
        export HALO_DATA_ROOT="$PWD"'

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Modern open-source Halo: Combat Evolved engine ecosystem";
      homepage = "https://github.com/chupathingy/chupathingy";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
halo-ce
