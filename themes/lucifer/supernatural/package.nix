{ unstable }:
unstable.hyprlandPlugins.mkHyprlandPlugin {
  pluginName = "HyprWindowShade";
  version = "2026-10-03-4414596";
  src = unstable.fetchzip {
    url = "https://github.com/ManofJELLO/HyprWindowShade/archive/4414596c2fbb64cb5bb4aa7342900051338fed7a.tar.gz";
    sha256 = "0a4abd94f4yc0a9wf5scmx9a5asxi7m4bw43rzlf120pfqpfww0m";
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
