{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nktfh100-lab";
}
