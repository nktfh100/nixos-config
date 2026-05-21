{...}:

{

  users.extraGroups.docker.members = [ "nktfh100" ];

  # Allow containers to reach host services (e.g. host.docker.internal)
  networking.firewall.trustedInterfaces = [ "docker0" ];

  # Allow rootless docker to bind port 80
  # boot.kernel.sysctl = { "net.ipv4.ip_unprivileged_port_start" = 80; };

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    # rootless = {
    #   enable = true;
    #   setSocketVariable = true;
    # };
  };
}
