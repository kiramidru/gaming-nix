{ lib, pkgs, ... }:
let
  pname = "devil-daggers";
  version = "3.2";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Devil Daggers";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://dn710400.ca.archive.org/0/items/devil-daggers-linux-gog-phoenix-games-lab/game-Devil_Daggers_%28v3.2%29_%5BLinux%2C_GOG%2C_Fixed_Libs%5D.tar.xz";
      sha256 = "sha256-3knRTFR99qju9ruv1l1EIqb3lxKScoZaxoQsq5SpLNg=";
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname}

      if [ -d "game" ]; then
        cp -r game/* $out/opt/${pname}/
      else
        cp -r * $out/opt/${pname}/
      fi

      chmod -R u+w $out/opt/${pname}
      find $out/opt/${pname} -type f -exec chmod +x {} +

      runHook postInstall
    '';
  };

  devil-daggers = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        stdenv.cc.cc.lib
        zlib
        glibc
        bash
        coreutils

        libGL
        libGLU
        vulkan-loader
        libxkbcommon
        libX11
        libXcursor
        libXrandr
        libXinerama
        libXi
        libXext
        libXxf86vm
        libXrender

        openal
        alsa-lib
        libpulseaudio
        udev
      ];

    multiPkgs =
      pkgs: with pkgs; [
        udev
        alsa-lib
        libGL
        libX11
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
      mkdir -p "$GAME_DIR/mods"

      for item in "${gameData}/opt/${pname}"/*; do
        target="$GAME_DIR/$(basename "$item")"
        if [ "$(basename "$item")" != "mods" ] && [ ! -e "$target" ]; then
          ln -s "$item" "$target"
        fi
      done

      cd "$GAME_DIR"
      exec ./devildaggers "$@"
    '';

    meta = with lib; {
      description = "Fast-paced FPS that pits you into an abyssal arena";
      homepage = "https://devildaggers.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
devil-daggers
