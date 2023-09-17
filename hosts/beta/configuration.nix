{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common.nix ];

  networking.hostName = "nktfh100-beta";

  environment.systemPackages = with pkgs; [ telegram-desktop ];
}
