{ lib, pkgs, ... }:
let
  pname = "celeste";
  version = "1.4.0";

  deps = with pkgs; [
    stdenv.cc.cc.lib
    SDL2
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Celeste";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  celeste = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/celeste-game-linux/game-Celeste_%28v1.4.0.0%29_%5BLinux%5D.tar.xz";
      sha256 = "sha256-O9LgGD8ek1sKcj9oKsdolktm+AYJblsYlqfav0plxuw=";
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
      autoPatchelfHook
      copyDesktopItems
    ];

    buildInputs = deps;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin
      cp -r . $out/opt/${pname}

      LIB_DIR="$out/opt/${pname}/lib64"

      makeWrapper ${pkgs.mono}/bin/mono $out/bin/${pname} \
        --add-flags $out/opt/${pname}/Celeste.exe \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath deps}:$LIB_DIR" \
        --prefix LD_PRELOAD : "$LIB_DIR/libfmod.so.10:$LIB_DIR/libfmodstudio.so.10"

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Narrative-driven, precision platformer about climbing a mountain";
      homepage = "https://www.celestegame.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
celeste
