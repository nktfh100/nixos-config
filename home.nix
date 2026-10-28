{
  pkgs,
  lib,
  unstable,
  ...
}:

{
  home.stateVersion = "24.05";
  home.username = "nktfh100";

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    # General
    htop
    wget
    fastfetch
    bitwarden-cli
    (google-chrome.override { commandLineArgs = "--force-dark-mode"; })
    (callPackage ./pkgs/webshot { })

    jq
    lsof

    psmisc # To use fuser

    # Video/Audio
    vlc
    audacity
    obs-studio

    # Social
    discord

    # Dev
    docker
    gh # Github CLI
    gnumake # Make
    unstable.godot

    # Coding language specific

    # Nix
    # nixfmt-classic

    # JS/TS
    nodejs_24
    yarn

    # Python
    python312

    # Python packages
    python312Packages.flake8 # Linter
    python312Packages.black # Formatter

    # Go
    gopls # Go language server
    delve # Go debugger
  ];

  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
    "video/mp4" = [ "vlc.desktop" ];
    "image/png" = [ "imv.desktop" ];
    "image/jpeg" = [ "imv.desktop" ];
    "image/gif" = [ "imv.desktop" ];
    "image/webp" = [ "imv.desktop" ];
    "image/bmp" = [ "imv.desktop" ];
    "image/tiff" = [ "imv.desktop" ];
    "image/svg+xml" = [ "imv.desktop" ];
    "image/avif" = [ "imv.desktop" ];
    "image/heic" = [ "imv.desktop" ];
    "image/heif" = [ "imv.desktop" ];
    "image/jxl" = [ "imv.desktop" ];
  };

  programs.home-manager.enable = true;

  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;
    skills = ./ai/skills;
    commandsDir = ./ai/commands;
    agentsDir = ./ai/agents;
    context = ./ai/AGENTS.md;
    settings = lib.importJSON ./claude/settings.json;
    mcpServers.rea = {
      command = "${pkgs.nodejs_24}/bin/npx";
      args = [
        "-y"
        "rea-agents@6.7.0"
        "mcp"
      ];
      env = {
        GHIDRA_INSTALL_DIR = "${unstable.ghidra}/lib/ghidra";
        JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
      };
    };
  };

  home.file = {
    ".claude/plugins/claude-hud/config.json".source = ./claude/claude-hud.json;
  };

  programs.command-not-found.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      nix-code = "code /etc/nixos";
      nix-garbage = "nix-env --delete-generations 30d && sudo nix-store --gc && sudo nix-collect-garbage -d && sudo nix store optimise && sudo rm -rf ~/.local/share/Trash/*";
      py = "python";
      dcb = "docker compose build";
      dcu = "docker compose up";
      dcud = "docker compose up";
      dcd = "docker compose down";
      dcsa = "docker stop $(docker ps -a -q)";
      dc = "docker compose";
    };
    bashrcExtra = ''
      nix-rebuild() {
        local flake_name="nktfh100-$1"
        local rebuild_subcommand=$2
        shift 2
        local extra_args="$@"

        if [[ "$flake_name" != "$(hostname)" ]]; then
            echo "Warning: The flake name '$flake_name' does not match the current hostname '$(hostname)'."
            read -p "Do you want to proceed? (y/N): " confirmation
            if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
                echo "Aborted."
                return 1
            fi
        fi

        sudo nixos-rebuild "$rebuild_subcommand" --flake "path:/etc/nixos#$flake_name" $extra_args
      }

      kill-port() {
        sudo fuser -k $1/tcp
      }
    '';
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nktfh100";
        email = "me@malachi.io";
      };
      credential.helper = "store";
      http.postBuffer = "524288000";
      submodule.recurse = "true";
    };
  };
}
