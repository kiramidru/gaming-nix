{ pkgs, ... }:

let
  pname = "llauncher";
  version = "1.40.3";

  deps = with pkgs; [
    glib
    gtk3
    cairo
    gdk-pixbuf
    pango
    atk

    libGL
    glfw
    openal
    udev
    libpulseaudio
    alsa-lib
    libX11
    libXext
    libXcursor
    libXrandr
    libXxf86vm
    libXinerama
    libXi
  ];

  jre = pkgs.jdk25;

  desktopItem = pkgs.makeDesktopItem {
    name = "minecraft";
    desktopName = "Minecraft";
    exec = "llauncher";
    icon = "minecraft";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  llauncher = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://dl.llaun.ch/legacy/bootstrap";
      hash = "sha256-Cbp1F8ipsweA/5pt4jC4kFJHg1rg2pFNZpkeKztLbE4=";
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
    ];

    buildInputs = deps;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/llauncher $out/bin
      cp $src $out/share/llauncher/llauncher.jar

      makeWrapper ${jre}/bin/java $out/bin/llauncher \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}  \
        --add-flags "-jar $out/share/llauncher/llauncher.jar" \
        --add-flags "--java-executable ${jre}/bin/java"

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with pkgs.lib; {
      description = "Minecraft launcher with offline and custom skin support (fork of SKlauncher)";
      homepage = "https://llaun.ch/";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      mainProgram = "llauncher";
    };
  };
in
llauncher
