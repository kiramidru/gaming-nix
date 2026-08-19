{ lib, pkgs, ... }:
let
  pname = "broforce";
  version = "3148";

  deps = with pkgs; [
    stdenv.cc.cc.lib
    libGL
    libglvnd
    libX11
    libXext
    libxkbcommon
    libXcursor
    libXrandr
    libXinerama
    libXi
    libXrender
    alsa-lib
    udev
    zlib
    libpulseaudio
    gtk2
    glib
    gdk-pixbuf
    vulkan-loader
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Broforce";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  broforce = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/broforce-linux-gog-phoenix-games-lab/broforce_forver_hf_linux_71321.sh";
      sha256 = "sha256-C8mbrqrKsrdJka9fP6/KDr8rmd8R9hohTfU33wRLV0Q=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      unzip
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = deps;

    unpackPhase = "unzip -q $src -d source || true";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin
      cp -r source/data/noarch/game/* $out/opt/${pname}

      makeWrapper $out/opt/${pname}/Broforce.x86_64 $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps} \
        --run '
          USER_GAME_DIR=''${XDG_DATA_HOME:-''$HOME/.local/share}/${pname}
          mkdir -p "$USER_GAME_DIR"
          ln -sfn $out/opt/${pname}/* "$USER_GAME_DIR/"
          cd "$USER_GAME_DIR"
        '

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Side-scrolling run-and-gun platform video game";
      homepage = "https://www.broforcegame.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
broforce
