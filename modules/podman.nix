{ ... }:

{
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  users.users.nktfh100 = {
    isNormalUser = true;
    extraGroups = [ "podman" ];
  };
}
