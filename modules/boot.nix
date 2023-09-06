{ pkgs, ... }:

{
  # Allow rootless docker to bind port 80
  boot.kernel.sysctl = { "net.ipv4.ip_unprivileged_port_start" = 80; };
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
