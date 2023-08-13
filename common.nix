{ config, pkgs, lib, nixpkgs, ... }:

let
  nktfh100-fonts = pkgs.callPackage ./fonts.nix { };
in
{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 3;

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
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  nix = {
    settings.experimental-features = [ "flakes" "nix-command" ];
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
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    hashedPassword = "$6$Zy11DU7hvzxe2Sh0$LBKmavFyJx/f3w22nktPL8/kJ8M/neU8agJFoddJi7rQnbMO0E8CdrqNKZ/XFHi08eWPn5pTuMBLaMMfsSh21.";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      nktfh100-fonts
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Allow rootless docker to bind port 80
  boot.kernel.sysctl = { "net.ipv4.ip_unprivileged_port_start" = 80; };

  environment.systemPackages = with pkgs; [
    firefox

    vscode

    git

    # File managment
    zip
    unzip
    unrar

    gparted
    ntfs3g # NTFS support for gparted
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.gnome.excludePackages = (with pkgs; [
    gnome-tour
  ]) ++ (with pkgs.gnome; [
    gnome-music
    gnome-weather
    gnome-clocks
    gnome-contacts
    gnome-characters
    epiphany
    geary
    totem
    tali
    iagno
    hitori
    atomix
  ]);

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment
}
