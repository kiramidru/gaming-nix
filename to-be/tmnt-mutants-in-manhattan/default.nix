{ lib, pkgs, ... }:
let
  pname = "tmnt-mutants-in-manhattan";
  version = "1.0.0";

  winePkg = pkgs.wineWowPackages.staging;

  deps = with pkgs; [
    winePkg
    dxvk
    bash
    coreutils
    libGL
    vulkan-loader
    libX11
    libpulseaudio
  ];
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  # Multiple sources fetched cleanly
  srcs = [
    (pkgs.fetchurl {
      name = "game-base.sh";
      url = "https://archive.org/download/teenage-mutant-ninja-turtles-mutants-in-manhattan_202508/Teenage%20Mutant%20Ninja%20Turtles%20-%20Mutants%20in%20Manhattan.7z";
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    })
    (pkgs.fetchurl {
      name = "online-fix.zip";
      url = "https://uploads.online-fix.me:2053/uploads/Teenage%20Mutant%20Ninja%20Turtles%20Mutants%20in%20Manhattan/Fix%20Repair/TMNTMiM_Fix_Repair_Steam_Generic.rar";
      sha256 = "sha256-BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=";
    })
  ];

  sourceRoot = ".";

  nativeBuildInputs = with pkgs; [
    p7zip
    unzip
    makeWrapper
  ];

  dontAutoPatchelf = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir -p game_temp fix_temp

    # 1. Unpack base game
    7z x "$srcs[0]" -ogame_temp
    PAYLOAD=$(find game_temp -type f \( -name "*.tar*" -o -name "*.7z*" -o -name "*data*" -o -name "*.zip" \) | head -n 1)
    if [ -n "$PAYLOAD" ]; then
      7z x "$PAYLOAD" -osource_game
    else
      cp -r game_temp/* source_game/
    fi

    # 2. Unpack Online-Fix patch
    unzip -o "$srcs[1]" -d fix_temp/ || 7z x "$srcs[1]" -ofix_temp/

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/${pname} $out/bin $out/libexec

    # Copy base game
    GAME_SRC=$(find source_game -type f -name "TMNT.exe" -printf '%h\n' | head -n 1)
    cp -r "$GAME_SRC/"* $out/opt/${pname}/

    # OVERWRITE with Online-Fix DLLs & configs
    cp -rf fix_temp/* $out/opt/${pname}/

    # Runner script
    cat << 'EOF' > $out/libexec/${pname}-bootstrap
    #!/usr/bin/env bash
    set -e

    export WINEARCH="win64"
    export WINEPREFIX="''${WINEPREFIX:-$HOME/.local/share/${pname}/wineprefix}"
    export DXVK_STATE_CACHE_PATH="$HOME/.local/share/${pname}"

    GAME_DIR="$HOME/.local/share/${pname}/game"
    mkdir -p "$GAME_DIR" "$WINEPREFIX"

    # Link patched files into user directory
    for item in "$1"/*; do
      target="$GAME_DIR/$(basename "$item")"
      if [ ! -e "$target" ]; then
        ln -s "$item" "$target"
      fi
    done

    cd "$GAME_DIR"

    # Online-Fix uses Steam AppID 480 (Spacewar) by default
    echo "480" > steam_appid.txt

    shift
    exec wine "$GAME_DIR/TMNT.exe" "$@"
    EOF

    chmod +x $out/libexec/${pname}-bootstrap

    makeWrapper "$out/libexec/${pname}-bootstrap" "$out/bin/${pname}" \
      --add-flags "$out/opt/${pname}" \
      --prefix PATH : "${
        lib.makeBinPath [
          winePkg
          pkgs.coreutils
          pkgs.bash
        ]
      }" \
      --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath deps}" \
      --set WINEDEBUG "-all" \
      --set DXVK_LOG_LEVEL "none" \
      --set DXVK_STATE_CACHE "1" \
      --set SteamAppId "480" \
      --set SteamGameId "480"

    runHook postInstall
  '';
}
