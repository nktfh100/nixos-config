{ pkgs, ... }:

{
  home-manager.users.nktfh100 = {
    home = {
      packages = with pkgs; [
        polybarFull
        playerctl
      ];
      file.".config/autostart/polybar.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Polybar
        Exec=polybar example
        X-GNOME-Autostart-enabled=true
      '';
    };
    programs.bash.bashrcExtra = ''
      restart-polybar() {
        polybar-msg cmd restart
      }
    '';
  };

  system.activationScripts.polybarSymLink.text = ''
    rm -f -r /home/nktfh100/.config/polybar
    ln -Ts /etc/nixos/modules/polybar/polybar-config /home/nktfh100/.config/polybar
  '';
}
