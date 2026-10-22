{ lib, pkgs, ... }:
let
  pname = "project-aim";
  version = "v0.1.0";

  desktopItem = pkgs.makeDesktopItem {
    name = pname;
    desktopName = "Project Aim";
    exec = pname;
    icon = pname;
    terminal = false;
    categories = [ "Game" ];
  };

  gameData = pkgs.stdenv.mkDerivation {
    pname = "${pname}-data";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/ahmadhayyan/project-aim/releases/download/${version}/Project-Aim_0.1.0_linux64.x86_64";
      hash = "sha256-YXquicb49rbiC+KjNTIC3KdXbEsHK2Io4Sk+APLYdrg=";
    };

    icon = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/ahmadhayyan/project-aim/${version}/icon.png";
      hash = "sha256-UYU7YPTqyIigmQNgXUXoIWJlOB2BUKmAe+A4I2PvXv0=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/opt/${pname}
      cp $src $out/opt/${pname}/${pname}
      chmod +x $out/opt/${pname}/${pname}
      cp $icon $out/opt/${pname}/icon.png

      runHook postInstall
    '';
  };

  project-aim = pkgs.buildFHSEnv {
    name = pname;

    targetPkgs =
      pkgs: with pkgs; [
        stdenv.cc.cc.lib
        glibc
        bash
        coreutils

        libGL
        libglvnd
        libxkbcommon
        libX11
        libXcursor
        libXrandr
        libXinerama
        libXi
        libXext
        libXrender
        libXfixes

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
      mkdir -p $out/share/applications $out/share/pixmaps
      cp ${desktopItem}/share/applications/* $out/share/applications/
      ln -s "${gameData}/opt/${pname}/icon.png" "$out/share/pixmaps/${pname}.png"
    '';

    runScript = pkgs.writeShellScript "${pname}-runner" ''
      exec "${gameData}/opt/${pname}/${pname}" "$@"
    '';

    meta = with lib; {
      description = "A simple and lightweight aim trainer game made with Godot";
      homepage = "https://github.com/ahmadhayyan/project-aim";
      platforms = platforms.linux;
      mainProgram = pname;
    };
  };
in
project-aim
