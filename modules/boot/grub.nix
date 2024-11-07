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
          # imgName = "bedrock";
          # https://www.reddit.com/r/NixOS/comments/1gjmpf9/i_made_this_nixos_in_minecraft_long_time_ago_for/
          customImg = builtins.path {
            path = ./nixos-logo.jpg;
            name = "nixos-img";
          };
        }];
      };
    };
  };
}
