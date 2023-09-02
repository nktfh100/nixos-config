
# NixOS Config

My personal NixOS configuration files I use for all my linux machines.

# Install

Steps:

* Install NixOS GNOME with nktfh100 as the username.
* Create a nix shell with git package
    ```
    nix-shell -p git
    ```
* Set PC variable
    ```
    # "lab" or "home"
    PC=""
    ```
* Run install script:
    ```
    # Take ownership of /etc/nixos
    sudo chown -R $USER /etc/nixos

    # Remove the default configuration file
    rm /etc/nixos/configuration.nix

    # Clone the repo to a temp folder
    git clone https://github.com/nktfh100/nixos-config /tmp/nixos

    # Copy repo to /etc/nixos
    cp -R /tmp/nixos /etc

    # Move new hardware-configuration file to the appropriate location for this machine
    mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/$PC-pc/

    # Rebuild
    cd /etc/nixos && sudo nixos-rebuild switch --flake .#nktfh100-$PC
    ```
* Reset layout
    ```
    gsettings reset org.gnome.desktop.input-sources xkb-options
    gsettings reset org.gnome.desktop.input-sources sources
    ```