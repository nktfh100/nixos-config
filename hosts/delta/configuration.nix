{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ../../common.nix ];

  networking.hostName = "nktfh100-delta";
}
