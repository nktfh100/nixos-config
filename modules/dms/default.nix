{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:

let
  isLucifer = config.my.theme == "lucifer";
  barFontScale = if isLucifer then 1.25 else 1.0;
  baseSettings = builtins.fromJSON (builtins.readFile ./settings.json);
  themeFile =
    if isLucifer then ../../themes/lucifer/dms/theme.json else ../../themes/catppuccin/dms/theme.json;
  wallpaperList =
    if isLucifer then
      ../../themes/lucifer/dms/wallpapers.json
    else
      ../../themes/catppuccin/dms/wallpapers.json;
  dmsPackage = import ./package.nix { inherit pkgs unstable; };
  powerMenu = pkgs.writeShellApplication {
    name = "theme-power";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
      pkgs.wlogout
    ];
    text = ''
      read -r horizontal vertical < <(
        hyprctl monitors -j | jq -r '
          [.[] | select(.focused)][0] |
          [(.width / .scale * 0.095 | floor), (.height / .scale * 0.26 | floor)] | @tsv'
      )
      exec wlogout -b 3 -c 14 -r 14 -L "$horizontal" -R "$horizontal" -T "$vertical" -B "$vertical"
    '';
  };
  catalog = pkgs.writeText "${config.my.theme}-wallpapers.json" (
    builtins.toJSON (
      map (
        item:
        item
        // {
          path = "${../../wallpapers + "/${builtins.baseNameOf item.path}"}";
        }
      ) (builtins.fromJSON (builtins.readFile wallpaperList))
    )
  );
  themedPlugin =
    name: source: extras:
    pkgs.runCommand "${config.my.theme}-${name}" { } ''
      mkdir -p $out
      cp -r ${source}/. $out/
      chmod -R u+w $out
      ${lib.optionalString (!isLucifer) ''
        ${pkgs.python3}/bin/python ${../../themes/catppuccin/dms/recolor.py} $out
      ''}
      ${extras}
    '';
  plugin = themedPlugin "dms-plugin" ./plugins/infernal ''
    cp ${catalog} $out/wallpapers.json
    ${lib.optionalString (!isLucifer) ''
      cp ${../../themes/catppuccin/dms/sigil.svg} $out/sigil.svg
      cp ${../../themes/catppuccin/dms/sigil.svg} $out/profile-sigil.svg
    ''}
  '';
  claudeUsage = themedPlugin "claude-usage" ./plugins/claudeUsage "";
  lockWallpaper = pkgs.runCommand "lucifer-lock-wallpaper.jpg" { nativeBuildInputs = [ pkgs.imagemagick ]; } ''
    magick ${../../wallpapers/infernal.png} -resize 1920x1080 -strip -quality 88 JPEG:$out
  '';
  settings = pkgs.writeText "${config.my.theme}-dms-settings.json" (
    builtins.toJSON (
      baseSettings
      // {
        barConfigs = map (bar: bar // { fontScale = barFontScale; }) baseSettings.barConfigs;
        customThemeFile = "${themeFile}";
        customPowerActionLock = "";
        lockScreenWallpaperPath =
          if isLucifer then
            "${lockWallpaper}"
          else
            "${../../wallpapers/nix-black.png}";
        lockScreenWallpaperFillMode = "Fill";
        loginctlLockIntegration = true;
        lockBeforeSuspend = true;
      }
    )
  );
  wallpaper = pkgs.writeShellApplication {
    name = "theme-wallpaper";
    runtimeInputs = [
      pkgs.python3
      pkgs.hyprpaper
      pkgs.hyprland
    ];
    text = ''
      export THEME_WALLPAPERS=${catalog}
      export DESKTOP_THEME=${config.my.theme}
      exec python ${./wallpaper.py} "$@"
    '';
  };
  lock = pkgs.writeShellApplication {
    name = "theme-lock";
    runtimeInputs = [ dmsPackage.dms ];
    text = ''
      exec dms ipc call lock lock
    '';
  };
  shell = pkgs.writeShellApplication {
    name = "theme-shell";
    runtimeInputs = [
      dmsPackage.dms
      unstable.quickshell
      pkgs.cava
      pkgs.python3
      pkgs.asusctl
      pkgs.systemd
      pkgs.coreutils
      wallpaper
    ];
    text = ''
      export DMS_HIDE_TRAYIDS=nm-applet,blueman
      export DMS_THEME=${config.my.theme}
      theme-wallpaper start &
      wallpaper_pid=$!
      trap 'kill "$wallpaper_pid" 2>/dev/null || true' EXIT
      trap 'exit 0' INT TERM
      dms run
    '';
  };
  summon = pkgs.writeShellApplication {
    name = "theme-summon";
    runtimeInputs = [
      pkgs.hyprland
      pkgs.jq
      pkgs.kitty
    ];
    text = ''
      if hyprctl clients -j | jq -e 'any(.[]; .workspace.name == "special:S")' >/dev/null; then
        hyprctl dispatch togglespecialworkspace S
      else
        hyprctl dispatch exec '[workspace special:S] kitty --class theme-summon'
      fi
    '';
  };
  motion = pkgs.writeShellApplication {
    name = "theme-motion-toggle";
    runtimeInputs = [
      dmsPackage.dms
      wallpaper
    ];
    text = ''
      if [[ ! -f "$XDG_RUNTIME_DIR/battery-desktop.json" && "$(dms ipc call settings get reduceMotion)" == "true" ]]; then
        dms ipc call settings set reduceMotion false
        theme-wallpaper reduce off
        ${lib.optionalString isLucifer "lucifer-smoke-mode on"}
      else
        dms ipc call settings set reduceMotion true
        theme-wallpaper reduce on
        ${lib.optionalString isLucifer "lucifer-smoke-mode off"}
      fi
    '';
  };
in
{
  security.pam.services.dankshell = { };
  services.gnome.gnome-keyring.enable = true;
  programs.dank-calendar = {
    enable = true;
    quickshell.package = unstable.quickshell;
    systemd.enable = true;
  };
  environment.systemPackages = [
    dmsPackage.dms
    unstable.quickshell
    pkgs.cava
    wallpaper
    shell
    motion
    lock
    summon
    powerMenu
  ];

  home-manager.users.nktfh100 = { lib, config, ... }: {
    home.activation.dankCalendarWeekStart = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      directory="${config.xdg.configHome}/dankcal"
      mkdir -p "$directory"
      if [[ -f "$directory/ui-settings.json" ]]; then
        ${pkgs.jq}/bin/jq '.firstDayOfWeek = 0' "$directory/ui-settings.json" > "$directory/ui-settings.json.new"
      else
        printf '%s\n' '{"firstDayOfWeek":0}' > "$directory/ui-settings.json.new"
      fi
      mv "$directory/ui-settings.json.new" "$directory/ui-settings.json"
    '';
    xdg.configFile."DankMaterialShell/plugins/infernal".source = plugin;
    xdg.configFile."DankMaterialShell/plugins/infernalMedia".source = ./plugins/infernalMedia;
    xdg.configFile."DankMaterialShell/plugins/infernalSpaces".source = ./plugins/infernalSpaces;
    xdg.configFile."DankMaterialShell/plugins/claudeUsage".source = claudeUsage;
    systemd.user.services.theme-shell = {
      Unit = {
        Description = "Desktop shell";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        Wants = [ "dcal.service" ];
      };
      Service = {
        ExecStart = "${shell}/bin/theme-shell";
        Restart = "always";
        RestartSec = 2;
      };
    };
    home.activation.themeShellDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      directory="${config.xdg.configHome}/DankMaterialShell"
      mkdir -p "$directory"
      if [[ -f "$directory/settings.json" ]]; then
        ${pkgs.jq}/bin/jq -s '.[0] + .[1] + (.[0] | with_entries(select(.key | test("^(currentThemeName|customThemeFile|customPowerActionLock|lockScreenWallpaperPath|lockScreenWallpaperFillMode|fontFamily|monoFontFamily|barConfigs|dashTabs|loginctlLockIntegration|lockBeforeSuspend|matugenTemplate.*|runUserMatugenTemplates)$")))) | .barConfigs |= map(.fontScale = ${toString barFontScale}) | .screenPreferences.wallpaper = []' \
          ${settings} "$directory/settings.json" > "$directory/settings.json.new"
        mv "$directory/settings.json.new" "$directory/settings.json"
      else
        install -m 644 ${settings} "$directory/settings.json"
      fi
      state_directory="${config.xdg.stateHome}/DankMaterialShell"
      mkdir -p "$state_directory"
      if [[ ! -e "$state_directory/desktop-idle-v1" && ! -e "$state_directory/lucifer-idle-v1" ]]; then
        ${pkgs.jq}/bin/jq '.acLockTimeout = 900 | .batteryLockTimeout = 900 | .acMonitorTimeout = 930 | .batteryMonitorTimeout = 930 | .acSuspendTimeout = 1200 | .batterySuspendTimeout = 1200 | .acPostLockMonitorTimeout = 0 | .batteryPostLockMonitorTimeout = 0' \
          "$directory/settings.json" > "$directory/settings.json.new"
        mv "$directory/settings.json.new" "$directory/settings.json"
        if [[ -f "$state_directory/session.json" ]]; then
          ${pkgs.jq}/bin/jq '.idleInhibited = true' "$state_directory/session.json" > "$state_directory/session.json.new"
          mv "$state_directory/session.json.new" "$state_directory/session.json"
        else
          printf '%s\n' '{"idleInhibited":true}' > "$state_directory/session.json"
        fi
      fi
      touch "$state_directory/desktop-idle-v1"
      if [[ -f "$directory/plugin_settings.json" ]]; then
        ${pkgs.jq}/bin/jq '.infernal.enabled = true | .infernalMedia.enabled = true | .infernalSpaces.enabled = true | .claudeUsage.enabled = true' "$directory/plugin_settings.json" > "$directory/plugin_settings.json.new"
        mv "$directory/plugin_settings.json.new" "$directory/plugin_settings.json"
      else
        printf '%s\n' '{"infernal":{"enabled":true},"infernalMedia":{"enabled":true},"infernalSpaces":{"enabled":true},"claudeUsage":{"enabled":true}}' > "$directory/plugin_settings.json"
      fi
    '';
  };
}
