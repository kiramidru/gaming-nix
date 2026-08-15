{ lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      pname = "until-then";
      version = "1.3";

      deps = with pkgs; [
        stdenv.cc.cc.lib
        udev
        alsa-lib
        libpulseaudio

        libX11
        libXcursor
        libXext
        libXrandr
        libXi
        vulkan-loader
      ];

      desktopItem = pkgs.makeDesktopItem {
        name = "until-then";
        desktopName = "Until Then";
        exec = "until-then";
        icon = "until-then";
        terminal = false;
        categories = [
          "Game"
        ];
      };
    in
    {
      packages.${pname} = pkgs.stdenv.mkDerivation {
        inherit pname version;

        src = pkgs.fetchurl {
          url = "https://archive.org/download/until_then_linux_linuxrulez/Until_Then_%28v1.3%29_%5BLinux%2C_LinuxRuleZ%21%5D.sh";
          sha256 = "sha256-QM5RjErrDA3nVFwAA/zMNYRha4kZRQ0B/NfZfJ5zt7A=";
        };

        nativeBuildInputs = with pkgs; [
          autoPatchelfHook
          makeWrapper
          p7zip
          copyDesktopItems
        ];

        buildInputs = deps;

        desktopItems = [ desktopItem ];

        unpackPhase = ''
          7z x $src -osource_temp
          PAYLOAD=$(find source_temp -type f | head -n 1)
          7z x "$PAYLOAD" -osource
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/${pname} $out/bin
          cp -r "source/Until Then/game/"* $out/opt/${pname}
          chmod +x $out/opt/${pname}/UntilThen.x86_64

          makeWrapper $out/opt/${pname}/UntilThen.x86_64 $out/bin/${pname} \
            --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath deps}

          runHook postInstall
        '';

        dontStrip = true;

      };
    };
}
