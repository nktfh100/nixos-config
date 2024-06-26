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

  boot.loader.grub = {
    device = "nodev";
    minegrub-world-sel = {
      enable = true;
      customIcons = [{
        name = "nixos";
        lineTop = "NixOS (23/11/2023, 23:03)";
        lineBottom = "Survival Mode, No Cheats, Version: 23.11";
        # imgName = "";
        # customImg = builtins.path {
        #   path = ../../nixos-icon.png;
        #   name = "nixos-img";
        # };
      }];
    };
  };

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  home-manager.users.nktfh100.home.packages = with pkgs; [ zoom-us slack ];
}
