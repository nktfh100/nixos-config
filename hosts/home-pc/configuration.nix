{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/gnome.nix
    ../../modules/nvidia.nix
    ../../modules/grub-theme/distro-grub-themes.nix
  ];

  networking.hostName = "nktfh100-home";
}
