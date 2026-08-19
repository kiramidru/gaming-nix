{ pkgs, lib, ... }:
let
  pname = "balatro";
  version = "1.0";

  deps = with pkgs; [
    stdenv.cc.cc.lib
    love
    luajit
    SDL2
    libGL
    openal
    libmodplug
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Balatro";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  balatro = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://archive.org/download/balatro-linux-love-linuxrulez/Balatro%20%28v.1.0.1o%29%20%2B%20Support%20for%20Mods%20and%20ARM%20added%20%5BLOVE%5D%20%5BLinuxRuleZ%21%5D.sh";
      hash = "sha256-uLUB5vL6lnVLUe3ecOvwUnCVcDsddDFdWEsjpRR8bZQ=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      makeWrapper
      p7zip
      copyDesktopItems
    ];

    buildInputs = deps;

    unpackCmd = ''

      ￼
            mkdir source
            7z x $src -osource
    '';

    installPhase = ''
      runHook preInstall
        
      ls -R .
      mkdir -p $out/opt/${pname} $out/bin
      cp -r source/Balatro/game/* $out/opt/${pname}

      makeWrapper ${pkgs.love}/bin/love $out/bin/${pname} \
        --add-flags "$out/opt/${pname}/balatro.love" \
        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "A poker-inspired roguelike deck builder";
      homepage = "https://www.playbalatro.com/";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
balatro
