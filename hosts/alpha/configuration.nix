{ pkgs, ... }:

# Gaming desktop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
  ];

  networking.hostName = "nktfh100-alpha";

  home-manager.users.nktfh100.home.packages = with pkgs; [
    zoom-us
  ];

}
