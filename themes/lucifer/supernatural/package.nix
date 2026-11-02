{ unstable }:
unstable.hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "HyprWindowShade";
  version = "2026-10-29-b62fc3d";
  src = unstable.fetchzip {
    url = "https://github.com/ManofJELLO/HyprWindowShade/archive/b62fc3d8d04514d7b51e61c281a34231b04e95e3.tar.gz";
    sha256 = "0g1xpd6sy751kzp00g2lwxn085jdcx8lh5hl8a6x9196fvl11h10";
  };
  buildInputs = [ unstable.libglvnd ];
  installPhase = ''
    mkdir -p $out/lib
    cp HyprWindowShade.so $out/lib/
  '';
  meta = {
    description = "Per-window shaders for Infernal demon-smoke close animations";
    license = unstable.lib.licenses.mit;
  };
}
