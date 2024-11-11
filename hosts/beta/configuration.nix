{ pkgs, ... }:

# Gaming/Work laptop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
  ];

  networking.hostName = "nktfh100-beta";

  environment.systemPackages = with pkgs; [ linux-wifi-hotspot ];

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  home-manager.users.nktfh100.home.packages = with pkgs; [ zoom-us ];

  # https://discourse.nixos.org/t/laptop-hangs-at-started-session-c1-of-user-gdm/26834/16
  hardware.nvidia.prime = {
    sync.enable = true;
    nvidiaBusId = "PCI:1:0:0";
    intelBusId = "PCI:0:2:0";
  };

  swapDevices = [{
    device = "/swapfile";
    size = 16 * 1024; # 16GB
  }];
}
