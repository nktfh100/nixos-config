{ lib, ... }:

{
  services.pipewire = {
    enable = lib.mkForce false;
  };
  services.pulseaudio.enable = true;
  nixpkgs.config.pulseaudio = true;
}
