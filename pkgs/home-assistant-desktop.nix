{
  stdenv,
  lib,
  buildNpmPackage,
  makeDesktopItem,
  fetchFromGitHub,
  electron,
  copyDesktopItems,
}:

# Stolen from https://github.com/Flo2410/dotnix/blob/main/pkgs/home-assistant-desktop.nix
let
  description = "Desktop application (Windows / macOS / Linux) for Home Assistant built with Electron";
in
buildNpmPackage rec {
  pname = "homeassistant-desktop";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "iprodanovbg";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Fu54mGYkJn92803QJOOkyL63I1yGi30OFWTEi1Y2IcM=";
  };

  npmDepsHash = "sha256-yrNGWqv13os54k5H7HpOPui/H8qQ1KHEh9oJG23cCW0=";

  nativeBuildInputs = [
    electron
    copyDesktopItems
  ];

  dontNpmBuild = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  postInstall = ''
    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/lib/node_modules/${pname}/app.js

    install -D build/icon.png $out/share/icons/${pname}.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "Home Assistant";
      comment = description;
    })
  ];

  meta = with lib; {
    homepage = "https://github.com/iprodanovbg/homeassistant-desktop";
    description = description;
    platforms = platforms.linux;
    maintainers = with maintainers; [ flo2410 ];
    changelog = "https://github.com/iprodanovbg/homeassistant-desktop/releases/tag/v${version}";
    license = licenses.asl20;
  };
}
