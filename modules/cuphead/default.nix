{ lib, pkgs, ... }:
let
  pname = "cuphead";
  version = "1.3.4";

  deps = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    gdk-pixbuf
    glib
    gtk2

    libglvnd
    libX11
    libXcursor
    libXext
    libXi
    libXinerama
    libXrandr
    libXScrnSaver
    libXxf86vm
    vulkan-loader

    alsa-lib
    libpulseaudio
    udev
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Cuphead";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };

  cuphead = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      name = "${pname}-${version}.sh";
      url = "https://archive.org/download/cuphead-linux-unofficial-port-linuxrulez-phoenix-games-lab/Cuphead%20%28v.1.3.4%29%20%2B%201%20DLC%20%5BUnity3D%5D%20%5BMULTi%5D%20%5BLinuxRuleZ%21%5D.sh";
      hash = "sha256-YpQDtAYz34UKrEKCvWCYVkmYS2wLtLh/8BM4siTcbPs=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      copyDesktopItems
      makeWrapper
      xz
    ];

    buildInputs = deps;
    dontStrip = true;

    unpackPhase = ''
      runHook preUnpack

      # Extract the appended tar.xz payload without running the installer.
      mkdir source
      tail -c 4653837888 "$src" | tar -xJf - -C source Cuphead/game

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/opt" "$out/bin"
      mv source/Cuphead/game "$out/opt/${pname}"

      install -Dm644 "$out/opt/${pname}/Cuphead_Data/Resources/UnityPlayer.png" \
        "$out/share/pixmaps/${pname}.png"

      makeWrapper "$out/opt/${pname}/Cuphead.x86_64" "$out/bin/${pname}" \
        --chdir "$out/opt/${pname}" \
        --set LC_ALL C \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath deps}

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Run-and-gun platformer with The Delicious Last Course DLC (unofficial Linux port)";
      homepage = "https://cupheadgame.com/";
      platforms = [ "x86_64-linux" ];
      mainProgram = pname;
    };
  };
in
cuphead
