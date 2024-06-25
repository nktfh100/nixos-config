{ pkgs, ... }:

# Alpha PC
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
    (import ../../modules/wallpaper.nix {
      wallpaper = "file:///etc/nixos/wallpapers/nix-black.png";
    })
  ];

  networking.hostName = "nktfh100-alpha";

  boot.loader.grub = { device = "nodev"; };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  home-manager.users.nktfh100.home.packages = with pkgs; [ zoom-us ];
}
