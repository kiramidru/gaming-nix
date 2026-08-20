{ lib, pkgs, ... }:
let
  pname = "crawl";
  version = "1.0.1";

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
    desktopName = "Crawl";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  crawl = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/crawl-game-linux-phoenix-games-lab/Crawl%20%28v.1.0.1%29%20%5BUnity3D%5D%20%5BLinuxRuleZ%21%5D.sh";
      sha256 = "sha256-AeX71Z3PliZJlNr3K9TH0z8JfuWB0b051PKePO4raaM=";
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
      cp -r source/Crawl/game/* $out/opt/${pname}

      chmod +x $out/opt/${pname}/Crawl.x86_64

      makeWrapper $out/opt/${pname}/Crawl.x86_64 $out/bin/${pname} \
        --run "mkdir -p ~/.local/share/Crawl" \
        --run "cd ~/.local/share/Crawl" \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Local multiplayer dungeon crawler where your friends control the monsters";
      homepage = "http://www.powerhoof.com/crawl/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
crawl
