{ lib, ... }:

{
  services.pipewire = {
    enable = lib.mkForce false;
  };
  hardware.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
}
