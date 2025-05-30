{ pkgs, unstable, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/hypr
    ln -Ts /etc/nixos/modules/hyperland/hyprland-config /home/nktfh100/.config/hypr
  '';

  programs.hyprland.enable = true;
  services.displayManager.sddm.enable = true;

  environment.systemPackages = with pkgs; [
    kitty # Terminal
    kdePackages.dolphin # File manager
    wofi # Application launcher
    nwg-displays # Monitor configuration
  ];

  # hint Electron apps to use Wayland:
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

}
