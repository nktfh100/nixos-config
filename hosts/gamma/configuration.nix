{ lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/boot/grub.nix
    ../../modules/nvidia.nix
  ];

  networking.hostName = "nktfh100-gamma";

  boot.loader.grub.device = "/dev/sda";
}
