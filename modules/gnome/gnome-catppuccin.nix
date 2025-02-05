{ pkgs, ... }:

let
  flavor = "macchiato";
  accent = "blue";
in
{
  catppuccin.grub.enable = false;

  catppuccin.plymouth.enable = true;

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
      gtk = {
        enable = true;
        gnomeShellTheme = true;
      };
    };
    gtk = {
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders;
      };
    };
  };
}
