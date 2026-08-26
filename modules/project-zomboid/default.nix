{ lib, pkgs, ... }:
let
  pname = "project-zomboid";
  version = "42.20.2";

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/project-zomboid-linux-gog/project_zomboid_42_20_2_92872.sh";
      sha256 = "sha256-4oMgL+oKIMeNNK2Uve1jR5J6HfMopxMjOZFxcXM6WNM=";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    unpackPhase = "unzip -q $src -d source || true";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname}
      cp -r source/data/noarch/game/projectzomboid/* $out/opt/${pname}

      chmod -R u+w $out/opt/${pname}
      find $out/opt/${pname} -type f -exec chmod +x {} +

      runHook postInstall
    '';
  };

  project-zomboid = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        stdenv.cc.cc.lib
        zlib
        glibc
        bash
        coreutils
        openjdk

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

    runScript = pkgs.writeShellScript "${pname}-runner" ''
      GAME_DIR="$HOME/.local/share/${pname}"
      mkdir -p "$GAME_DIR"

      find "$GAME_DIR" -maxdepth 1 -type l -delete 2>/dev/null || true

      cp -Ru "${gameData}/opt/${pname}/." "$GAME_DIR/"

      if [ -d "$GAME_DIR/media/fonts" ]; then
        for f in "$GAME_DIR/media/fonts/"*.fnt; do
          [ -f "$f" ] || continue
          base=$(basename "$f")
          [ -e "$GAME_DIR/media/$base" ] || ln -sf "fonts/$base" "$GAME_DIR/media/$base"
        done
      fi

      mkdir -p "$GAME_DIR/mods"

      cd "$GAME_DIR"

      export LD_LIBRARY_PATH=".:$GAME_DIR/natives:$LD_LIBRARY_PATH"

      export JAVA_HOME="$GAME_DIR/jre64"
      export PATH="$JAVA_HOME/bin:$PATH"

      exec ./ProjectZomboid64 "$@"
    '';

    meta = with lib; {
      description = "An open-ended zombie infestation sandbox";
      homepage = "https://projectzomboid.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
project-zomboid
