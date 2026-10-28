{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  plugin = import ./package.nix { inherit unstable; };
  mode = pkgs.writeShellApplication {
    name = "lucifer-smoke-mode";
    runtimeInputs = [
      unstable.hyprland
      pkgs.jq
    ];
    text = ''
      case "''${1:-auto}" in
        auto)
          settings="''${XDG_CONFIG_HOME:-$HOME/.config}/DankMaterialShell/settings.json"
          if [[ -f "$settings" ]] && jq -e '.reduceMotion == true' "$settings" >/dev/null; then
            exec "$0" off
          fi
          exec "$0" on
          ;;
        on)
          if ! hyprctl plugin list -j | jq -e 'any(.[]; .name == "HyprWindowShade")' >/dev/null; then
            hyprctl plugin load ${plugin}/lib/HyprWindowShade.so
          fi
          ;;
        off)
          if hyprctl plugin list -j | jq -e 'any(.[]; .name == "HyprWindowShade")' >/dev/null; then
            hyprctl plugin unload ${plugin}/lib/HyprWindowShade.so
          fi
          ;;
        *) exit 2 ;;
      esac
    '';
  };
in
{
  options.my.lucifer.openEffect = lib.mkOption {
    type = lib.types.enum [
      "none"
      "angel-wings"
      "devils-reflection"
      "devils-trap"
      "hellfire-reveal"
      "angel-arrival"
      "demon-smoke"
      "reality-fracture"
      "haunted-signal"
    ];
    default = "hellfire-reveal";
    description = "Window opening shader for the Lucifer desktop.";
  };

  options.my.lucifer.closeEffect = lib.mkOption {
    type = lib.types.enum [
      "demon-close"
      "angel-grace"
      "burning-wings"
      "hellfire-edges"
      "shattered-ward"
      "pentecostal-coin"
      "salt-and-burn"
    ];
    default = "pentecostal-coin";
    description = "Window close effect for the Lucifer desktop.";
  };

  config = lib.mkIf (config.my.theme == "lucifer") {
    environment.systemPackages = [ mode ];
  };
}
