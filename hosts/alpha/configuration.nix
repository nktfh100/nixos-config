{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    (import ../../modules/wallpaper.nix {
      wallpaper = "file:///etc/nixos/wallpapers/wallhaven-j3m8y5.png";
    })
  ];

  networking.hostName = "nktfh100-alpha";
}
