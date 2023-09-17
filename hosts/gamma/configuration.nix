{ ... }:

{
  imports =
    [ ./hardware-configuration.nix ../../common.nix ../../modules/nvidia.nix ];

  networking.hostName = "nktfh100-gamma";
}
