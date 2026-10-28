{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./supernatural
  ];

  config = lib.mkIf (config.my.theme == "lucifer") {
    fonts.packages = [ pkgs.alegreya-sans ];

    console.colors = [
      "201820"
      "ff5364"
      "a6da95"
      "eed49f"
      "8aadf4"
      "c6a0f6"
      "8bd5ca"
      "d6cabe"
      "b7a6b0"
      "e99aa3"
      "c1e6aa"
      "f6dfb4"
      "abc6f7"
      "d7b8fa"
      "a7e3da"
      "f7edf0"
    ];

    boot.loader.grub.gfxmodeEfi = "1920x1080,1600x900,1280x720,1024x768,auto";
    boot.loader.grub.theme =
      pkgs.runCommand "lucifer-grub"
        {
          nativeBuildInputs = [
            pkgs.grub2
            pkgs.imagemagick
            pkgs.librsvg
          ];
        }
        ''
          mkdir -p $out
          cp ${./grub/theme.txt} $out/theme.txt
          sed 's|<rect width="3840" height="2160" fill="url(#night)"/>||' ${../../wallpapers/infernal-nix.svg} > artwork.svg
          rsvg-convert -w 960 -h 540 artwork.svg -o artwork.png
          magick -size 1920x1080 xc:'#000000' artwork.png -geometry +480+0 -composite PNG32:$out/background.png
          grub-mkfont -s 24 -o $out/menu.pf2 ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf
          grub-mkfont -s 16 -o $out/help.pf2 ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf
          magick -size 8x8 xc:'#1c1c1c' PNG32:$out/selected_c.png
          magick -size 5x8 xc:'#ff5364' PNG32:$out/selected_w.png
        '';

    programs.spicetify.customColorScheme = import ./spicetify-palette.nix;

    programs.firefox = {
      policies.Preferences = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.theme.toolbar-theme" = 0;
        "browser.theme.content-theme" = 0;
      };
    };

    home-manager.users.nktfh100 = {
      home.file.".mozilla/firefox/37hs0f43.default/chrome/userChrome.css".source = ./firefox.css;
      home.file.".config/fastfetch/config.jsonc".source = ./fastfetch.jsonc;
      programs.bash.initExtra = ''
        PS1='\[\e[38;2;255;83;100m\]\u@\h \[\e[38;2;187;169;176m\]\w \[\e[38;2;255;83;100m\]❯ \[\e[0m\]'
      '';
      gtk = {
        theme = {
          name = "Adwaita-dark";
          package = pkgs.gnome-themes-extra;
        };
        iconTheme = {
          name = "Tela-red-dark";
          package = pkgs.tela-icon-theme;
        };
        font = {
          name = "Alegreya Sans";
          size = 10;
        };
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk3.extraCss = builtins.readFile ./gtk/gtk.css;
        gtk4.theme = null;
        gtk4.extraCss = builtins.readFile ./gtk/gtk.css + builtins.readFile ./gtk/gtk4.css;
        cursorTheme = {
          name = "catppuccin-macchiato-red-cursors";
          package = pkgs.catppuccin-cursors.macchiatoRed;
          size = 24;
        };
      };
      home.pointerCursor = {
        name = "catppuccin-macchiato-red-cursors";
        package = pkgs.catppuccin-cursors.macchiatoRed;
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };
      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "Fusion";
      };
      xdg.configFile = builtins.listToAttrs (
        map
          (version: {
            name = "qt${version}ct/qt${version}ct.conf";
            value.text = ''
              [Appearance]
              color_scheme_path=${./qt-colors.conf}
              custom_palette=true
              icon_theme=Tela-red-dark
              standard_dialogs=default
              style=Fusion

              [Fonts]
              fixed="ComicCodeLigatures Nerd Font,11,-1,5,50,0,0,0,0,0"
              general="Alegreya Sans,10,-1,5,50,0,0,0,0,0"
            '';
          })
          [
            "5"
            "6"
          ]
      );
    };
  };
}
