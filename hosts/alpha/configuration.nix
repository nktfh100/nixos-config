{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    (import ../../modules/wallpaper.nix {
      wallpaper = "file:///etc/nixos/wallpapers/nix-black.png";
    })
  ];

  networking.hostName = "nktfh100-alpha";

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot =
    true; # powers up the default Bluetooth controller on boot

  hardware.pulseaudio.configFile = pkgs.writeText "default.pa" ''
    load-module module-bluetooth-policy
    load-module module-bluetooth-discover
    ## module fails to load with
    ##   module-bluez5-device.c: Failed to get device path from module arguments
    ##   module.c: Failed to load module "module-bluez5-device" (argument: ""): initialization failed.
    # load-module module-bluez5-device
    # load-module module-bluez5-discover
  '';
}
