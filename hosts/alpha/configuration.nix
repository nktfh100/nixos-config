{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    (import ../../modules/wallpaper.nix {
      wallpaper = "file:///etc/nixos/wallpapers/nix-black.png";
    })
  ];

  networking.hostName = "nktfh100-alpha";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot
}
