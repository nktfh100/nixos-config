{ ... }:

{
  home-manager.users.nktfh100.programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    userSettings = {
      "update.mode" = "none";
      "files.encoding" = "utf8";
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnSave" = true;
      "editor.fontFamily" = "'ComicCodeLigatures Nerd Font'";
      "editor.fontLigatures" = false;
      "prettier.tabWidth" = 4;
      "prettier.useTabs" = true;
      "[nix]"."editor.tabSize" = 2;
      "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
      "[python]"."editor.defaultFormatter" = "ms-python.black-formatter";
      "[yaml]"."editor.defaultFormatter" = "redhat.vscode-yaml";
      "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "workbench.colorTheme" = "Catppuccin Macchiato";
      "glassit.alpha" = 204;
    };
  };

  # To fix vscode blank screen
  home-manager.users.nktfh100.home.file.".vscode/argv.json".text = ''
    {
      "disable-hardware-acceleration": true,
      "enable-crash-reporter": false,
    }
  '';
}
