{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nktfh100-lab";

  environment.systemPackages = with pkgs; [ telegram-desktop ];
}
