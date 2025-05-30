{ pkgs, unstable, ... }:

{
  imports = [
    ./modules/boot
    ./modules/gnome
    ./modules/pulseaudio.nix
    ./modules/vscode
    ./modules/docker.nix
    ./modules/kitty
    ./modules/spicetify.nix
    ./modules/zoxide.nix
    ./modules/neovim
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.users.nktfh100 = ./home.nix;

  nixpkgs.config.allowUnfree = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Jerusalem";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IL";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "he_IL.UTF-8";
    LC_IDENTIFICATION = "he_IL.UTF-8";
    LC_MEASUREMENT = "he_IL.UTF-8";
    LC_MONETARY = "he_IL.UTF-8";
    LC_NAME = "he_IL.UTF-8";
    LC_NUMERIC = "he_IL.UTF-8";
    LC_PAPER = "he_IL.UTF-8";
    LC_TELEPHONE = "he_IL.UTF-8";
    LC_TIME = "he_IL.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    # Configure keymap in X11
    xkb.layout = "us,il";
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  nix = {
    settings.experimental-features = [
      "flakes"
      "nix-command"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  users.mutableUsers = false;
  # Define user accounts. Set password hash via `mkpasswd -m sha-512`
  users.users.root = {
    initialHashedPassword = "$6$Zy11DU7hvzxe2Sh0$LBKmavFyJx/f3w22nktPL8/kJ8M/neU8agJFoddJi7rQnbMO0E8CdrqNKZ/XFHi08eWPn5pTuMBLaMMfsSh21.";
  };

  users.users.nktfh100 = {
    isNormalUser = true;
    description = "Malachi";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
    ];
    hashedPassword = "$6$Zy11DU7hvzxe2Sh0$LBKmavFyJx/f3w22nktPL8/kJ8M/neU8agJFoddJi7rQnbMO0E8CdrqNKZ/XFHi08eWPn5pTuMBLaMMfsSh21.";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      (pkgs.callPackage ./pkgs/fonts { })
      nerd-fonts.fira-code
    ];
  };

  # services.teamviewer.enable = true;

  environment.systemPackages = with pkgs; [
    unstable.firefox
    git
    ffmpeg_6-full

    pavucontrol # PulseAudio volume control

    # File managment
    zip
    unzip
    unrar

    gparted
    ntfs3g # NTFS support for gparted

    # openssl_3_3

    go
  ];

  environment.variables = {
    "EDITOR" = "nvim";
    "VISUAL" = "nvim";
    "NODE_OPTIONS" = "--max_old_space_size=8192";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment
}
