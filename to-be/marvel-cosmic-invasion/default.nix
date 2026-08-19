{ pkgs, lib, ... }:
let
  pname = "marvel-cosmic-invasion";
  version = "1.0.0.12456";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Marvel Cosmic Invasion";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/marvel-cosmic-invasion-linux-linuxrulez/MARVEL_Cosmic_Invasion_%28v1.0.0.12456%29_%5BLinux%2C_Steam-Rip%2C_LinuxRuleZ%21%2C_Goldberg-Steam-Emulator%5D.sh";
      hash = "sha256-9Imdm9brQa4fFpodQEcNYImf15KOAAbDlqXYToBtXhE=";
    };

    nativeBuildInputs = with pkgs; [
      bash
      coreutils
      gnused
      gawk
      gnutar
      xz
      zstd
      p7zip
      unzip
      findutils
      which
    ];

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p extracted $out/opt/${pname}

      # Prepare executable installer script
      cp "$src" ./installer.sh
      chmod +x ./installer.sh

      # YAD Simple Installer uses '-e' to extract the embedded archive into current directory
      cd extracted
      bash ../installer.sh -e || true
      cd ..

      # Fallback if '-e' produced nothing
      if [ -z "$(ls -A extracted 2>/dev/null)" ]; then
        echo "YAD -e did not unpack directly, attempting 7z/unzip extraction..."
        7z x "$src" -oextracted -y || unzip "$src" -d extracted || true
      fi

      # Check for nested archive payloads (e.g. data.tar.xz, game.zip, etc.)
      PAYLOAD=$(find extracted -type f \( -name "*.tar*" -o -name "*.7z*" -o -name "*data*" -o -name "*.zip" \) ! -name "$src" | head -n 1)
      if [ -n "$PAYLOAD" ]; then
        7z x "$PAYLOAD" -o$out/opt/${pname} -y || cp -r extracted/* $out/opt/${pname}/
      elif [ -d "extracted/game" ]; then
        cp -r extracted/game/* $out/opt/${pname}/
      else
        cp -r extracted/* $out/opt/${pname}/
      fi

      # Ensure binaries and scripts are executable
      chmod -R u+w $out/opt/${pname}
      find $out/opt/${pname} -type f -exec chmod +x {} +

      runHook postInstall
    '';
  };
  marvel-cosmic-invasion = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        # Base runtime
        stdenv.cc.cc.lib
        zlib
        glibc
        bash
        coreutils
        gnused
        gawk
        which
        procps

        # Graphics & X11 / Wayland (Using non-deprecated package names)
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

        # Audio & System
        alsa-lib
        libpulseaudio
        openal
        udev
        libusb1
        dbus
        freetype
        fontconfig

        # SDL / Game Dependencies
        SDL2
        SDL2_image
        SDL2_mixer
        SDL2_ttf
        cabextract
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

      ICON=$(find "${gameData}/opt/${pname}" -type f \( -name "*.png" -o -name "*.ico" \) | head -n 1)
      if [ -n "$ICON" ]; then
        ln -s "$ICON" "$out/share/pixmaps/${pname}.png"
      fi
    '';

    runScript = pkgs.writeShellScript "${pname}-runner" ''
      GAME_DIR="$HOME/.local/share/${pname}"
      mkdir -p "$GAME_DIR"

      # Re-link static assets to persistent writable working directory
      if [ ! -e "$GAME_DIR/game" ]; then
        ln -sfn "${gameData}/opt/${pname}" "$GAME_DIR/game"
      fi

      cd "$GAME_DIR/game"

      # Search for launcher
      if [ -f "./start" ]; then
        exec ./start "$@"
      elif [ -f "./start.sh" ]; then
        exec ./start.sh "$@"
      fi

      TARGET_SCRIPT=$(find . -maxdepth 3 -type f \( -name "*start*.sh" -o -name "*start*" \) | head -n 1)
      if [ -n "$TARGET_SCRIPT" ]; then
        DIR=$(dirname "$TARGET_SCRIPT")
        cd "$DIR"
        exec "./$(basename "$TARGET_SCRIPT")" "$@"
      fi

      BIN=$(find . -maxdepth 3 -type f \( -name "*.x86_64" -o -name "*OpenBOR*" -o -name "*.elf" -o -name "*.exe" \) | head -n 1)
      if [ -n "$BIN" ]; then
        DIR=$(dirname "$BIN")
        cd "$DIR"
        exec "./$(basename "$BIN")" "$@"
      fi

      echo "Error: Could not find launch script. Directory contents:"
      ls -laR .
      exit 1
    '';

    meta = with lib; {
      description = "Marvel Cosmic Invasion (Steam-Rip LinuxRuleZ)";
      homepage = "https://archive.org/details/marvel-cosmic-invasion-linux-linuxrulez";
      platforms = [ "x86_64-linux" ];
      mainProgram = pname;
    };
  };
in
marvel-cosmic-invasion
