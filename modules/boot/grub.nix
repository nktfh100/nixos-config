{ ... }:

{
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      useOSProber = true;
      configurationLimit = 10;
    };
  };
}