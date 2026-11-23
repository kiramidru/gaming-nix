{ lib, pkgs, ... }:
let
  pname = "libreaim";
  version = "0.3.0-alpha";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "LibreAim";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/Nokorpo/LibreAim/releases/download/v${version}/LibreAim-v0.3.0-linux.x86_64";
      hash = "sha256-+De8ehPjSZ4O0MDW7cwPVLMl/VDXki8ytwYGkE9i8No=";
    };

    icon = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/Nokorpo/LibreAim/v${version}/icon.svg";
      hash = "sha256-2HBVmLk2w1vrKvlFDCViUzJ9phWa99MNDJLDNFs1EOk=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname}
      cp $src $out/opt/${pname}/${pname}
      chmod +x $out/opt/${pname}/${pname}
      cp $icon $out/opt/${pname}/icon.svg

      runHook postInstall
    '';
  };

  libreaim = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        stdenv.cc.cc.lib
        glibc
        bash
        coreutils

        libGL
        libglvnd
        vulkan-loader
        libxkbcommon
        libX11
        libXcursor
        libXrandr
        libXinerama
        libXi
        libXext
        libXrender
        libXfixes

        wayland
        libdecor
        dbus
        fontconfig
        speechd-minimal

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
      ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/pixmaps $out/share/icons/hicolor/scalable/apps
      cp ${desktopItem}/share/applications/* $out/share/applications/
      ln -s "${gameData}/opt/${pname}/icon.svg" "$out/share/pixmaps/${pname}.svg"
      ln -s "${gameData}/opt/${pname}/icon.svg" "$out/share/icons/hicolor/scalable/apps/${pname}.svg"
    '';

    runScript = pkgs.writeShellScript "${pname}-runner" ''
      exec "${gameData}/opt/${pname}/${pname}" "$@"
    '';

    meta = with lib; {
      description = "Free and open source FPS aim trainer made with Godot";
      homepage = "https://github.com/Nokorpo/LibreAim";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
libreaim
