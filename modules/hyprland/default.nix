{
  pkgs,
  unstable,
  ...
}:

let
  layoutNotify = pkgs.writeShellApplication {
    name = "hypr-layout-notify";
    runtimeInputs = [
      pkgs.socat
      pkgs.libnotify
    ];
    text = ''
      socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
      socat -U - "UNIX-CONNECT:$socket" | while read -r line; do
        case "$line" in
          activelayout*) notify-send -t 1500 -h string:x-canonical-private-synchronous:layout "⌨  ''${line##*,}" ;;
        esac
      done
    '';
  };
in
{
  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  programs.hyprland.package = unstable.hyprland;
  programs.hyprland.portalPackage = unstable.xdg-desktop-portal-hyprland;
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
    };
  };
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    layoutNotify # Popup showing the new keyboard layout on switch

    hyprpolkitagent # Authorization agent for Hyprland
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
    imv
    wlogout # Logout menu
    gnome-system-monitor # System monitor

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

  programs.firefox.enable = true;
  home-manager.users.nktfh100.gtk.enable = true;

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":close";
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
