{ lib, pkgs, ... }:
let
  pname = "halo-ce";
  version = "v0.7.2e";

  deps = with pkgs; [
    sdl3
    libGL
    stdenv.cc.cc.lib
    zlib
    openssl
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Halo CE";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [
      "Game"
    ];
  };

  halo-ce = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://github.com/ChupathingyCE/chupathingyce/releases/download/${version}/chupathingyce-linux-release.zip";
      sha256 = "sha256-t66SPBJGy/VBydHCQsTBIr8Upiu9PqNXHemZ8KTXtZ4=";
    };

    mapSrc = ./halo-xbox-maps.zip;

    nativeBuildInputs = [
      pkgs.autoPatchelfHook
      pkgs.unzip
      pkgs.makeWrapper
      pkgs.copyDesktopItems
    ];

    buildInputs = deps;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname} $out/bin $out/opt/${pname}/maps
      cp -r * $out/opt/${pname}/

      ls -R $out/opt/${pname}
      chmod +x $out/opt/${pname}/halo

      makeWrapper $out/opt/${pname}/halo $out/bin/${pname} \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath deps} 

      runHook postInstall
    '';

    desktopItems = [ desktopItem ];

    meta = with lib; {
      description = "Modern open-source Halo: Combat Evolved engine ecosystem";
      homepage = "https://github.com/chupathingy/chupathingy";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
halo-ce
