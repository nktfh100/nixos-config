{ config, pkgs, modulesPath, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ../../modules/grub-theme/minegrub.nix { options-count = 4; })
  ];

  networking.hostName = "nktfh100-lab";

  environment.systemPackages = with pkgs; [ telegram-desktop ];
}
