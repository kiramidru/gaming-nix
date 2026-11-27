{ pkgs, ... }:
let
  pname = "minecraft-launcher";
  version = "1.40.3";

  runtimeLibs = with pkgs; [
    glib
    gtk3
    cairo
    gdk-pixbuf
    pango
    atk

    libGL
    vulkan-loader
    wayland
    libxkbcommon
    libdecor
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
  launcher = "legacy-launcher";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Minecraft Launcher";
    exec = launcher;
    icon = "minecraft-launcher";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  minecraft-launcher = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://dl.llaun.ch/legacy/bootstrap";
      hash = "sha256-0eVbRzHqW02TnBTRZbIOA6tqMIzZhekyibj5V6RP6TI=";
    };

    nativeBuildInputs = with pkgs; [
      copyDesktopItems
      makeWrapper
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      launcherJar="$out/share/${launcher}/${launcher}.jar"
      install -Dm644 "$src" "$launcherJar"

      makeWrapper ${jre}/bin/java "$out/bin/${launcher}" \
        --prefix LD_LIBRARY_PATH : ${pkgs.addDriverRunpath.driverLink}/lib:${pkgs.lib.makeLibraryPath runtimeLibs} \
        --set _JAVA_AWT_WM_NONREPARENTING 1 \
        --add-flags "-jar $launcherJar" \
        --add-flags "--java-executable ${jre}/bin/java"

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with pkgs.lib; {
      description = "Minecraft launcher with offline and custom skin support (formerly TL Legacy)";
      homepage = "https://llaun.ch/";
      platforms = platforms.linux;
      mainProgram = launcher;
    };
  };
in
minecraft-launcher
