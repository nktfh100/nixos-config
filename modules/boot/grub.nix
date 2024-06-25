{ ... }:

{
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      useOSProber = true;
      efiSupport = true;
      configurationLimit = 10;
    };
  };
}
