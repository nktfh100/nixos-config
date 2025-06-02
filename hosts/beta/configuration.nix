{ pkgs, ... }:

# Gaming/Work laptop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
    ../../modules/tailscale.nix
  ];

  networking.hostName = "nktfh100-beta";

  environment.systemPackages = with pkgs; [ linux-wifi-hotspot ];

  home-manager.users.nktfh100.home.packages = with pkgs; [
    zoom-us
    asusctl
  ];

  services.asusd.enable = true;

  # https://discourse.nixos.org/t/laptop-hangs-at-started-session-c1-of-user-gdm/26834/16
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16 * 1024; # 16GB
    }
  ];
}
