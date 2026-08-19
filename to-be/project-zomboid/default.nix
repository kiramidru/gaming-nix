{ lib, pkgs, ... }:

let
  pname = "project-zomboid";
  version = "42.20.2";

  deps = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    SDL2
    gtk2
    gdk-pixbuf
    glib

    libGL
    libGLU
    libX11
    libXcursor
    libXrandr
    libXinerama
    libXi
    libXext
    libXrender
    alsa-lib
    udev
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Project Zomboid";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  gris = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/project-zomboid-linux-gog/project_zomboid_42_20_2_92872.sh";

      sha256 = "sha256-8vE9A0GYyjeoU6j84Nuq7Cbstqa3y/IVfNfcNNu9bQM=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      p7zip
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = deps;

    unpackPhase = ''
      7z x $src -osource_temp
      PAYLOAD=$(find source_temp -type f | head -n 1)
      7z x "$PAYLOAD" -osource
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin
      cp -r source/GRIS/game/* $out/opt/${pname}
      chmod +x $out/opt/${pname}/Gris.x86_64

      makeWrapper $out/opt/${pname}/Gris.x86_64 $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps} 

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Serene and evocative narrative platformer and puzzle game";
      homepage = "https://nomada.studio/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
gris
