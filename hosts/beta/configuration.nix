{ pkgs, ... }:

# Work laptop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/boot/grub.nix
  ];

  networking.hostName = "nktfh100-beta";

  # environment.systemPackages = with pkgs; [  ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  home-manager.users.nktfh100.home.packages = with pkgs; [ zoom-us slack ];
}
