{ pkgs, ... }:

let
  pname = "legacy-launcher";
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
    name = "legacy-launcher";
    desktopName = "Legacy Launcher";
    exec = "legacy-launcher";
    icon = "minecraft";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  legacy-launcher = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://dl.llaun.ch/legacy/bootstrap";
      hash = "sha256-Cbp1F8ipsweA/5pt4jC4kFJHg1rg2pFNZpkeKztLbE4=";
    };

    nativeBuildInputs = with pkgs; [
      copyDesktopItems
      makeWrapper
    ];

    buildInputs = deps;

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/legacy-launcher $out/bin
      cp $src $out/share/legacy-launcher/legacy-launcher.jar

      makeWrapper ${jre}/bin/java $out/bin/legacy-launcher \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}  \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --add-flags "-jar $out/share/legacy-launcher/legacy-launcher.jar" \
        --add-flags "--java-executable ${jre}/bin/java"

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with pkgs.lib; {
      description = "Minecraft launcher with offline and custom skin support (formerly TL Legacy)";
      homepage = "https://llaun.ch/";
      license = licenses.gpl3Only;
      platforms = platforms.linux;
      mainProgram = "legacy-launcher";
    };
  };
in
legacy-launcher
