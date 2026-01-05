{ pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.qemu = {
    package = pkgs.qemu;
  };

  users.users.nktfh100.extraGroups = [
    "libvirtd"
    "qemu-libvirtd"
  ];

  environment.systemPackages = with pkgs; [
    qemu
    virt-manager
    qemu-utils
    virt-viewer
  ];
}
