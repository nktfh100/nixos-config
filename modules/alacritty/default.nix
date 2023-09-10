{ pkgs, ... }:

{
  environment.sessionVariables.TERMINAL = "alacritty";
  environment.sessionVariables.WINIT_UNIX_BACKEND = "x11";

  home-manager.users.nktfh100.programs.alacritty = {
    enable = true;
    settings = {
      import = [ "/etc/nixos/modules/alacritty/catppuccin-macchiato.yml" ];
      window = { opacity = 0.8; };
      font = {
        normal = {
          family = "ComicCodeLigatures Nerd Font";
          style = "Regular";
        };
        bold = {
          family = "ComicCodeLigatures Nerd Font";
          style = "Bold";
        };
        italic = {
          family = "ComicCodeLigatures Nerd Font";
          style = "Italic";
        };
      };
    };
  };

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      "exec" = "exec ~/.nix-profile/bin/alacritty";
      "exec-arg" = "--working-directory";
    };
  };
}
