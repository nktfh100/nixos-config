{ pkgs, unstable }:
let
  assets =
    pkgs.runCommand "infernal-trap-assets"
      {
        nativeBuildInputs = [ unstable.qt6.qtshadertools ];
      }
      ''
            mkdir -p $out
        cp ${./lock/TrapSeal.qml} $out/TrapSeal.qml
        cp ${./lock/devils-trap.jpg} $out/devils-trap.jpg
        cp ${./lock/trap.frag} $out/trap.frag
            qsb --glsl "100 es,120,150" -o $out/trap.frag.qsb $out/trap.frag
      '';
  dms = unstable.dux-shell.overrideAttrs (old: {
    preBuild = ''
      chmod -R u+w ../quickshell
      ${pkgs.python3}/bin/python ${./lock/patch-lock.py} ../quickshell/Modules/Lock/LockScreenContent.qml
      mkdir -p ../quickshell/Modules/Lock/InfernalEffects
      cp ${assets}/* ../quickshell/Modules/Lock/InfernalEffects/
    ''
    + old.preBuild;
  });
in
{
  inherit assets dms;
}
