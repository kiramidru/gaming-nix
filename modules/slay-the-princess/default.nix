{ lib, pkgs, ... }:
let
  pname = "slay-the-princess";
  version = "80450";

  deps = with pkgs; [
    libGL
    libX11
    libXcursor
    libXext
    libXfixes
    libXi
    libXinerama
    libXrandr
    libXScrnSaver
    libXxf86vm
    alsa-lib
    dbus
    libpulseaudio
    udev
  ];

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Slay the Princess — The Pristine Cut";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://archive.org/download/slay-the-princess-the-pristine-cut-linux-gog-phoenix-games-lab/slay_the_princess_the_pristine_cut_slay_the_princess_the_pristine_cut_march_5_linux_80450.sh";
    # Checksum published in the Internet Archive item metadata.
    hash = "sha1-eGTe/fHhxc9skdvViaJ0/3QBjw8=";
  };

  nativeBuildInputs = with pkgs; [
    autoPatchelfHook
    unzip
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = deps;

  unpackPhase = ''
    runHook preUnpack

    # The shell installer prepends bytes to the ZIP64 archive; unzip reports a warning (1).
    unzip -q "$src" 'data/noarch/game/*' 'data/noarch/support/icon.png' -d source || test "$?" -eq 1

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    gameDir="$out/opt/${pname}"
    mkdir -p "$out/opt" "$out/bin"
    mv source/data/noarch/game "$gameDir"

    # Reassemble the Ren'Py asset archive as the GOG post-install script does.
    archive="$gameDir/game/archive.rpa"
    mv "$archive.split00" "$archive"
    cat "$archive.split01" >> "$archive"
    rm "$archive.split01"

    makeWrapper "$gameDir/SlaythePrincess.sh" "$out/bin/${pname}" \
      --chdir "$gameDir" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath deps}

    install -Dm644 source/data/noarch/support/icon.png \
      "$out/share/icons/hicolor/128x128/apps/${pname}.png"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = with lib; {
    description = "Branching psychological horror visual novel";
    homepage = "https://blacktabbygames.itch.io/slay-the-princess";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
