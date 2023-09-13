{ pkgs, ... }:

{
  boot.loader = {
    timeout = 10;
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      enable = true;
      useOSProber = true;
      configurationLimit = 10;
      efiSupport = true;
      device = "nodev";
    };
  };
}
