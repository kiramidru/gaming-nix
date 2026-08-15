{ lib, pkgs, ... }:

let
  pname = "gris";
  version = "1.03";

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
    name = "gris";
    desktopName = "Gris";
    exec = "gris";
    icon = "gris";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  gris = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/gris-unofficial-linux-port-linuxrulez-phoenix-games-lab/GRIS%20%28v.1.03%29%20%2B%20Bonus%20%5BFixed%5D%20%5BUnity3D%5D%20%5BGOG%5D%20%5BLinuxRuleZ%21%5D.sh";
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

    meta = {
      description = "Private, fast, and honest web browser based on ungoogled-chromium";
      homepage = "https://helium.computer/";
      license = lib.licenses.gpl3Only;
      platforms = [
        "x86_64-linux"
      ];
      mainProgram = "gris";
    };
  };
in
gris
