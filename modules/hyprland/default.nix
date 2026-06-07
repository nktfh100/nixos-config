{
  pkgs,
  config,
  ...
}:

let
  flavor = "macchiato";
  accent = "blue";
  homeDir = config.users.users.nktfh100.home;
in
{
  system.activationScripts.hyprlandSymLink.text = ''
    rm -f -r ${homeDir}/.config/hypr
    ln -Ts /etc/nixos/modules/hyprland/hyprland-config ${homeDir}/.config/hypr

    touch ${homeDir}/.config/hypr/profile.conf
    echo "\$HOSTNAME = ${config.networking.hostName}" > ${homeDir}/.config/hypr/profile.conf
  '';

  system.activationScripts.waybarSymLink.text = ''
    rm -f -r ${homeDir}/.config/waybar
    ln -Ts /etc/nixos/modules/hyprland/waybar-config ${homeDir}/.config/waybar
  '';

  system.activationScripts.rofiSymLink.text = ''
    rm -f -r ${homeDir}/.config/rofi
    ln -Ts /etc/nixos/modules/hyprland/rofi-config ${homeDir}/.config/rofi
  '';

  system.activationScripts.wlogoutSymLink.text = ''
    rm -f -r ${homeDir}/.config/wlogout
    ln -Ts /etc/nixos/modules/hyprland/wlogout-config ${homeDir}/.config/wlogout
  '';

  home-manager.users.nktfh100.home.file.".config/mako/config".text = ''
    default-timeout=3000
  '';

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  services.displayManager.sddm.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    hyprpolkitagent # Authorization agent for Hyprland
    mako # Notification daemon
    hypridle # Idle management
    wl-clipboard # Clipboard
    wl-clip-persist # Keep clipboard contents after source app closes/loses selection

    udiskie # Automount USB drives
    networkmanagerapplet # Network manager applet (tray icon)
    pwvucontrol # PulseAudio volume control
    brightnessctl # brightness control

    kitty # Terminal
    nautilus # File manager
    gnome-calculator # Calculator
    rofi # Application launcher
    eog # Image viewer
    wlogout # Logout menu
    gnome-system-monitor # System monitor

    waybar # Status bar
    hyprlock # Screen locker
    hyprpaper # Wallpaper manager

    hyprshot # take screenshots
    hyprpicker # Color picker
    nwg-displays # Monitor configuration
    # nwg-look # GTK settings editor

    playerctl # Media player control

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
      nvim.enable = false;
    };
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
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
      button-layout = ":close";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

}
