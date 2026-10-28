{
  pkgs,
  unstable,
  ...
}:
let
  dmsPackage = import ../../modules/dms/package.nix { inherit pkgs unstable; };
  desktop = pkgs.writeShellApplication {
    name = "battery-desktop";
    runtimeInputs = [
      pkgs.python3
      pkgs.brightnessctl
      pkgs.asusctl
      unstable.hyprland
    ];
    text = ''
      export BATTERY_DESKTOP_DMS=${dmsPackage.dms}/bin/dms
      exec python3 ${./battery-desktop.py}
    '';
  };
in
{
  services.auto-cpufreq.enable = false;
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me nouveau radeon nvidia xhci_hcd";
      RUNTIME_PM_ENABLE = "01:00.0 01:00.1";
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersave";
      SOUND_POWER_SAVE_ON_AC = 10;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      USB_AUTOSUSPEND = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_BTUSB = 1;
      DEVICES_TO_DISABLE_ON_STARTUP = "";
      DEVICES_TO_DISABLE_ON_SHUTDOWN = "";
      DEVICES_TO_DISABLE_ON_BAT = "";
      DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "";
      DEVICES_TO_ENABLE_ON_AC = "";
      RESTORE_DEVICE_STATE_ON_STARTUP = 1;
    };
  };

  services.asusd.asusdConfig.text = ''
    (
      charge_control_end_threshold: 100,
      base_charge_control_end_threshold: 0,
      disable_nvidia_powerd_on_battery: true,
      ac_command: "",
      bat_command: "",
      platform_profile_linked_epp: false,
      platform_profile_on_battery: Quiet,
      change_platform_profile_on_battery: true,
      platform_profile_on_ac: Performance,
      change_platform_profile_on_ac: true,
      profile_quiet_epp: Power,
      profile_balanced_epp: BalancePower,
      profile_custom_epp: Performance,
      profile_performance_epp: Performance,
      ac_profile_tunings: {},
      dc_profile_tunings: {},
      armoury_settings: {},
    )
  '';

  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  users.users.nktfh100.extraGroups = [ "video" ];
  services.udev.packages = [ pkgs.brightnessctl ];
  environment.systemPackages = [ desktop ];
  systemd.services.docker-prune.unitConfig.ConditionACPower = true;
  systemd.services.fstrim.unitConfig.ConditionACPower = true;

  home-manager.users.nktfh100.systemd.user.services.battery-desktop = {
    Unit = {
      Description = "Laptop battery desktop settings";
      After = [
        "graphical-session.target"
        "theme-shell.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${desktop}/bin/battery-desktop";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
