{
  config,
  lib,
  pkgs,
  ...
}:

let
  greeterTheme =
    {
      catppuccin = "border=blue;title=blue;greet=magenta;prompt=blue;time=blue;action=blue;button=magenta;container=black;input=cyan";
      lucifer = "border=#ff5364;title=#ff5364;greet=#f7edf0;prompt=#ff5364;time=#bba9b0;action=#ff5364;button=#ff9aa4;container=#54212f;input=#f7edf0";
    }
    .${config.my.theme};
  tuigreetCommand = lib.concatStringsSep " " [
    "${pkgs.tuigreet}/bin/tuigreet"
    "--time"
    "--user-menu"
    "--remember"
    "--remember-user-session"
    "--asterisks"
    "--greeting 'Welcome back, nktfh100'"
    "--window-padding 2"
    "--container-padding 2"
    "--prompt-padding 1"
    "--sessions /run/current-system/sw/share/wayland-sessions"
    "--theme '${greeterTheme}'"
  ];
  hyprConfig = pkgs.runCommand "${config.my.theme}-hypr-${config.networking.hostName}" { } ''
    mkdir -p $out/hosts $out/scripts
    cp -r ${./. + "/${config.my.theme}/hypr"}/. $out/
    cp ${../modules/hyprland/hyprland-config/hyprland.conf} $out/hyprland.conf
    cp ${../modules/hyprland/hyprland-config/environment.conf} $out/environment.conf
    cp ${../modules/hyprland/hyprland-config/input.conf} $out/input.conf
    cp ${../hosts/alpha/hyprland.conf} $out/hosts/nktfh100-alpha.conf
    cp ${../hosts/beta/hyprland.conf} $out/hosts/nktfh100-beta.conf
    cp ${../modules/hyprland/hyprland-config/scripts/cycle_ws.py} $out/scripts/cycle_ws.py
    chmod -R u+w $out
    echo '$HOSTNAME = ${config.networking.hostName}' > $out/profile.conf
    ${lib.optionalString (config.networking.hostName == "nktfh100-beta") ''
      substituteInPlace $out/environment.conf \
        --replace-fail 'env = LIBVA_DRIVER_NAME,nvidia' 'env = LIBVA_DRIVER_NAME,iHD' \
        --replace-fail 'env = __GLX_VENDOR_LIBRARY_NAME,nvidia' ""
    ''}
    ${lib.optionalString (config.my.theme == "lucifer") ''
      substituteInPlace $out/autostart.conf \
        --replace-fail /etc/nixos/themes/lucifer/supernatural/close/demon-close.glsl ${
          ./lucifer/supernatural/close + "/${config.my.lucifer.closeEffect}.glsl"
        }
      ${lib.optionalString (config.my.lucifer.openEffect != "none") ''
                echo 'windowrule = match:class .*, tag +shader_open_default:${
                  ./lucifer/supernatural/open + "/${config.my.lucifer.openEffect}.glsl"
                }' >> $out/autostart.conf
                cat >> $out/animations.conf <<'EOF'
        animations {
            animation = windowsIn, 0
            animation = fadeIn, 0
        }
        EOF
      ''}
    ''}
  '';
  rofiConfig =
    if config.my.theme == "lucifer" then
      pkgs.runCommand "lucifer-rofi" { } ''
        mkdir -p $out
        cp -r ${./lucifer/rofi}/. $out/
        chmod -R u+w $out
        substituteInPlace $out/config.rasi \
          --replace-fail /etc/nixos/themes/lucifer/rofi/artwork.png ${./lucifer/rofi/artwork.png}
      ''
    else
      ./catppuccin/rofi;
  wlogoutConfig =
    if config.my.theme == "lucifer" then
      pkgs.runCommand "lucifer-wlogout" { } ''
        mkdir -p $out
        cp -r ${./lucifer/wlogout}/. $out/
        chmod -R u+w $out
        substituteInPlace $out/style.css \
          --replace-fail /etc/nixos/wallpapers/infernal.png ${../wallpapers/infernal.png} \
          --replace-fail /etc/nixos/themes/lucifer/wlogout/icons ${./lucifer/wlogout/icons}
      ''
    else
      ./catppuccin/wlogout;
in
{
  imports = [
    ./catppuccin
    ./lucifer
  ];

  options.my.theme = lib.mkOption {
    type = lib.types.enum [
      "catppuccin"
      "lucifer"
    ];
    default = "lucifer";
    description = "Desktop theme for this machine.";
  };

  config = {
    services.greetd.settings.default_session.command = tuigreetCommand;
    systemd.tmpfiles.rules = [ "d /var/cache/tuigreet 0755 greeter greeter - -" ];
    system.activationScripts.migrateThemeConfigLinks.text = ''
      for name in hypr rofi wlogout waybar; do
        path="${config.users.users.nktfh100.home}/.config/$name"
        if [ -L "$path" ]; then
          case "$(readlink "$path")" in
            /nix/store/*-"$name"|/nix/store/*-"$name"-*)
              rm -- "$path"
              ;;
          esac
        fi
      done
    '';
    home-manager.users.nktfh100 = {
      xdg.configFile."hypr".source = hyprConfig;
      xdg.configFile."rofi".source = rofiConfig;
      xdg.configFile."wlogout".source = wlogoutConfig;
      home.file.".config/kitty/kitty.conf".source = ./. + "/${config.my.theme}/kitty.conf";
      home.file.".config/opencode/tui.json".source = ./. + "/${config.my.theme}/tui.json";
      home.file.".config/Code/User/settings.json".text = builtins.toJSON (
        builtins.fromJSON (builtins.readFile ../modules/vscode/settings.json)
        // builtins.fromJSON (builtins.readFile (./. + "/${config.my.theme}/vscode.json"))
      );
    };
  };
}
