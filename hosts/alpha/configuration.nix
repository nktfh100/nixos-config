{ pkgs, ... }:

# Gaming desktop
{
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/nvidia.nix
    ../../modules/boot/grub.nix
    ../../modules/virtualisation.nix
    ../../modules/podman.nix
  ];

  networking.hostName = "nktfh100-alpha";

  home-manager.users.nktfh100.home.packages = with pkgs; [
    zoom-us

    # To allow multi architecture builds
    (docker.override (args: {
      buildxSupport = true;
    }))
  ];

  # Force profile for razer headphones
  services.pipewire.wireplumber.extraConfig."51-razer-barracuda" = {
    "monitor.alsa.rules" = [
      {
        matches = [
          {
            "device.name" = "~alsa_card.usb-1532_Razer_Barracuda_X_2.4*";
          }
        ];
        actions = {
          update-props = {
            "device.profile" = "output:iec958-stereo+input:mono-fallback";
          };
        };
      }
    ];
  };
}
