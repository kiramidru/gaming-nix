{ lib, pkgs, ... }:

let
  pname = "dungreed";
  version = "1.7.6";

  deps = with pkgs; [

  ];

  desktopItem = pkgs.makeDesktopItem {
    name = "dungreed";
    desktopName = "Dungreed";
    exec = "dungreed";
    icon = "dungreed";
    terminal = false;
    categories = [
      "Game"
    ];
  };

  gris = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/dungreed_linux_linuxrulez_steamrip/Dungreed_%28v1.7.6%29_%5BLinux%2C_Steam-Rip%2C_LinuxRuleZ%21%2C_Goldberg-Steam-Emulator%5D.sh";
      sha256 = "sha256-NagumTj7LKa5GWc7HGLC0vIcKck2whhXkQB534Ln26M=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      p7zip
      makeWrapper
      copyDesktopItems
    ];

    buildInputs = deps;

    unpackPhase = ''
            runHook preUnpack

      export HOME="$(mktemp -d)"

          # Extract Layer 1
          7z x "$src" -osource

            runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin
      cd source
      cd bi6zjvy3y*
      ls -R source
      cp -r source/data/noarch/game/* $out/opt/${pname}

      makeWrapper $out/opt/${pname}/Broforce.x86_64 $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps} \
        --run '
          USER_GAME_DIR=''${XDG_DATA_HOME:-''$HOME/.local/share}/${pname}
          mkdir -p "$USER_GAME_DIR"
          ln -sfn $out/opt/${pname}/* "$USER_GAME_DIR/"
          cd "$USER_GAME_DIR"
        '

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = {
      description = "Private, fast, and honest web browser based on ungoogled-chromium";
      homepage = "https://helium.computer/";
      license = lib.licenses.gpl3Only;
      platforms = [
        "x86_64-linux"
      ];
      mainProgram = "dungreed";
    };
  };
in
gris
