{ lib, pkgs, ... }:
let
  pname = "tmnt-shredders-revenge";
  version = "1.0.0.349";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "TMNT: Shredder's Revenge";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/tmnj-shredders-revenge-linux-steam-rip-linuxrulez-phoenix-games-lab/Teenage_Mutant_Ninja_Turtles_%20Shredder%27s_Revenge_%28v1.0.0.349%29_%5BLinux%2C_Steam-Rip%2C_LinuxRuleZ%21%2C_Goldberg-Steam-Emulator%5D.sh";
      sha256 = "sha256-GL0bgxr3h682Y041ZJASKLCdJPMImNpf2tOK/cBU/fo=";
    };

    nativeBuildInputs = with pkgs; [
      p7zip
    ];

    unpackPhase = ''
      runHook preUnpack

      7z x $src -osource_temp
      PAYLOAD=$(find source_temp -type f | head -n 1)
      7z x "$PAYLOAD" -osource

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin
      cp -r "source/Teenage Mutant Ninja Turtles Shredder's Revenge/game/"* "$out/opt/${pname}/"

      runHook postInstall
    '';
  };

  tmnt-shredders-revenge = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        mono
        stdenv.cc.cc.lib
        zlib
        glibc
        bash
        coreutils

        # Graphics & Display
        libGL
        libGLU
        vulkan-loader
        libdecor
        libxkbcommon
        libX11
        libXcursor
        libXrandr
        libXinerama
        libXi
        libXext
        libXxf86vm
        libXrender
        libXtst
        libXcomposite

        # Audio & Input
        openal
        alsa-lib
        libpulseaudio
        udev
        libusb1
        dbus

        # Runtime GUI & Fonts
        gtk2
        freetype
        fontconfig
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf

        ffmpeg
        libtheora
        libvorbis
        libogg
        flac
      ];

    multiPkgs =
      pkgs: with pkgs; [
        udev
        alsa-lib
        libGL
        libX11
        libXext
        zlib
      ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/pixmaps
      cp ${desktopItem}/share/applications/* $out/share/applications/

      if [ -f "${gameData}/opt/${pname}/TMNT.png" ]; then
        ln -s "${gameData}/opt/${pname}/TMNT.png" "$out/share/pixmaps/${pname}.png"
      elif [ -f "${gameData}/opt/${pname}/icon.png" ]; then
        ln -s "${gameData}/opt/${pname}/icon.png" "$out/share/pixmaps/${pname}.png"
      fi
    '';

    runScript = pkgs.writeShellScript "${pname}-runner" ''
      # Mono & Environment Settings
      export MONO_IOMAP=all
      export FONTCONFIG_LOG=0
      export XMODIFIERS=""
      export LANG="C.UTF-8"
      export LC_ALL="C.UTF-8"

      # Graphics & Driver Settings
      export mesa_glthread=false
      export SDL_VIDEODRIVER="x11"
      export SDL_AUDIODRIVER="pulseaudio"
      export FNA3D_FORCE_DRIVER=Vulkan

      # Goldberg Steam Emulator Flags
      export SteamAppId="1361510"
      export SteamGameId="1361510"

      GAME_DIR="$HOME/.local/share/${pname}"
      mkdir -p "$GAME_DIR"

      # Symlink game assets
      for item in "${gameData}/opt/${pname}"/*; do
        target="$GAME_DIR/$(basename "$item")"
        if [ ! -e "$target" ]; then
          ln -s "$item" "$target"
        fi
      done

      cd "$GAME_DIR"

      # Library Paths
      export LD_LIBRARY_PATH="$GAME_DIR/lib64:$GAME_DIR/lib:/lib64:/usr/lib64:$LD_LIBRARY_PATH"

      exec mono "$GAME_DIR/TMNT.exe" "$@"
    '';

    meta = with lib; {
      description = "Teenage Mutant Ninja Turtles: Shredder's Revenge";
      homepage = "https://www.shredders-revenge.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
tmnt-shredders-revenge
