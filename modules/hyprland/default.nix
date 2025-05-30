{ pkgs, unstable, ... }:

{
  system.activationScripts.hyprlandSymLink.text = ''
    rm -f -r /home/nktfh100/.config/hypr
    ln -Ts /etc/nixos/modules/hyprland/hyprland-config /home/nktfh100/.config/hypr
  '';

  system.activationScripts.makoSymLink.text = ''
    rm -f -r /home/nktfh100/.config/mako/config
    ln -Ts /etc/nixos/modules/hyprland/mako-config /home/nktfh100/.config/mako/config
  '';

  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    kitty # Terminal
    kdePackages.dolphin # File manager
    wofi # Application launcher
    nwg-displays # Monitor configuration
    waybar # Status bar
    wl-clipboard # Clipboard
    hyprshot # take screenshots
    hyprpicker # Color picker

    mako # Notification daemon
    # hyprpaper # Wallpaper manager
  ];

  # hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

}
