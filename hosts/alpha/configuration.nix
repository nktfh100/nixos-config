{ pkgs, ... }:

# Gaming desktop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
    # (import ../../modules/wallpaper.nix { wallpaper = "file:///etc/nixos/wallpapers/nix-black.png"; })
  ];

  networking.hostName = "nktfh100-alpha";

  home-manager.users.nktfh100.home.packages = with pkgs; [
    zoom-us
  ];

}
