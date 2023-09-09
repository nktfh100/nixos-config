{ ... }:

{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "nktfh100" ];
  virtualisation.virtualbox.host.enableExtensionPack = true;
}
