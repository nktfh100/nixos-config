{ pkgs, lib, ... }:

{
  boot.loader = {
    timeout = 10;
    efi = lib.mkDefault {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    systemd-boot = lib.mkDefault {
      enable = true;
      configurationLimit = 10;
    };
  };
}
