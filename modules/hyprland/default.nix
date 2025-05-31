{
  pkgs,
  unstable,
  config,
  ...
}:

let
  flavor = "macchiato";
  accent = "blue";
in
{
  system.activationScripts.hyprlandSymLink.text = ''
    rm -f -r /home/nktfh100/.config/hypr
    ln -Ts /etc/nixos/modules/hyprland/hyprland-config /home/nktfh100/.config/hypr

    touch /home/nktfh100/.config/hypr/profile.conf
    echo "\$HOSTNAME = ${config.networking.hostName}" > /home/nktfh100/.config/hypr/profile.conf
  '';

  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    kitty # Terminal
    nautilus # File manager
    kdePackages.gwenview # Image viewer
    kdePackages.kcalc # Calculator
    wl-clipboard # Clipboard
    mako # Notification daemon
    hyprpolkitagent # Authorization agent for Hyprland
    overskride # Bluetooth
    networkmanagerapplet # Network manager applet (tray icon)
    udiskie # Automount USB drives
    waybar # Status bar
    hyprshot # take screenshots
    hyprpicker # Color picker
    wofi # Application launcher
    nwg-displays # Monitor configuration
    # hyprpaper # Wallpaper manager

    # nwg-look # GTK settings editor
    hyprls # hyprland LSP
    tree-sitter-grammars.tree-sitter-hyprlang # For neovim syntax highlighting
  ];

  # hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  catppuccin = {
    enable = true;
    flavor = flavor;
    accent = accent;
    grub.enable = false;
    plymouth.enable = true;
  };

  # To fix: "Only the Qt 6 version of SDDM is supported by this port!"
  services.displayManager.sddm.package = pkgs.kdePackages.sddm;

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
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.catppuccin-papirus-folders;
      };
      cursorTheme = {
        name = "catppuccin-macchiato-blue-cursors";
        package = pkgs.catppuccin-cursors.macchiatoBlue;
        size = 32;
      };
    };
  };

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      # button-layout = ":minimize,maximize,close";
      button-layout = ":close";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      # enable-hot-corners = true;
      # gtk-enable-primary-paste = false;
    };
  };

}
