{ ... }:

{
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      device = "nodev";
      useOSProber = true;
      efiSupport = true;
      configurationLimit = 10;
      minegrub-world-sel = {
        enable = true;
        customIcons = [{
          name = "nixos";
          lineTop = "NixOS (24/05/2024, 23:03)";
          lineBottom = "Survival Mode, No Cheats, Version: 24.05";
          imgName = "bedrock";
          # customImg = builtins.path {
          #   path = ../../nixos-icon.png;
          #   name = "nixos-img";
          # };
        }];
      };
    };
  };
}
