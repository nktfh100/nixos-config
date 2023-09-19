{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/boot/grub.nix
    (import ../../modules/wallpaper.nix {
      wallpaper = "file:///etc/nixos/wallpapers/at.jpeg";
    })
  ];

  networking.hostName = "nktfh100-beta";

  environment.systemPackages = with pkgs; [ telegram-desktop ];

  boot.loader.efi = { efiSysMountPoint = "/boot/efi"; };
  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
  };
}
