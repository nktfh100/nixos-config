{ pkgs, ... }:

# Gaming/Work laptop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
    ../../modules/tailscale.nix
    ../../modules/virtualization.nix
  ];

  networking.hostName = "nktfh100-beta";

  environment.systemPackages = with pkgs; [ linux-wifi-hotspot ];

  home-manager.users.nktfh100.home.packages = with pkgs; [
    zoom-us
    asusctl
  ];

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };

  services.asusd.enable = true;

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    sync.enable = false;
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
