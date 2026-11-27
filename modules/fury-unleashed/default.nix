{ lib, pkgs, ... }:
let
  pname = "fury-unleashed";
  version = "1.9.1.1";

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
    desktopName = "Fury Unleashed";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  fury-unleashed = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/fury-unleashed-linux-gog-phoenix-games-lab/fury_unleashed_1_9_1_1_83003.sh";
      hash = "sha256-lY7lAArQevwjI5txgzLoXVz+BFPXzn1YDd7GmSl9ifg=";
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

      makeWrapper "$out/opt/${pname}/FuryUnleashed.x86_64" "$out/bin/${pname}" \
        --chdir "$out/opt/${pname}" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath deps}

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Combo-driven roguelite action platformer";
      homepage = "https://www.furyunleashed.net/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
fury-unleashed
