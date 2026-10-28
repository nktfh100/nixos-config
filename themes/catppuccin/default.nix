{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = lib.mkIf (config.my.theme == "catppuccin") {
    catppuccin = {
      enable = true;
      flavor = "macchiato";
      accent = "blue";
      grub.enable = false;
      plymouth.enable = true;
    };

    boot.loader.grub.minegrub-world-sel = {
      enable = true;
      customIcons = [
        {
          name = "nixos";
          lineTop = "NixOS (25/05/2024, 23:03)";
          lineBottom = "Survival Mode, No Cheats, Version: 25.05";
          customImg = builtins.path {
            path = ./grub/nixos-logo.jpg;
            name = "nixos-img";
          };
        }
      ];
    };

    programs.spicetify.colorScheme = "macchiato";

    home-manager.users.nktfh100 = {
      catppuccin = {
        enable = true;
        flavor = "macchiato";
        accent = "blue";
        nvim.enable = false;
      };
      gtk = {
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        cursorTheme = {
          name = "catppuccin-macchiato-blue-cursors";
          package = pkgs.catppuccin-cursors.macchiatoBlue;
          size = 32;
        };
      };
      home.pointerCursor = {
        name = "catppuccin-macchiato-blue-cursors";
        package = pkgs.catppuccin-cursors.macchiatoBlue;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
    };
  };
}
