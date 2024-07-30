{ pkgs, ... }:

let
  flavor = "macchiato";
  accent = "blue";
in {
  boot.loader.grub.catppuccin.enable = false;

  boot.plymouth.catppuccin.enable = true;

  catppuccin = {
    enable = true;
    flavor = flavor;
    accent = accent;
  };

  home-manager.users.nktfh100 = {
    catppuccin = {
      enable = true;
      flavor = flavor;
      accent = accent;
    };
    gtk = {
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders;
      };
      catppuccin = {
        enable = true;
        gnomeShellTheme = true;
      };
    };
  };
}
