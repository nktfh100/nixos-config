
# NixOS Config

My personal NixOS configuration files.

Catppuccin themed!

# Images

![](assets/screenshot_1.png)


# Install

Steps:

* Install NixOS GNOME with nktfh100 as the username.
* Create a nix shell with git package
    ```
    nix-shell -p git
    ```
* Set PC variable
    ```
    # Based on hosts folder
    PC=""
    ```
* Run install script:
    ```
    # Take ownership of /etc/nixos
    sudo chown -R $USER /etc/nixos

    # Remove the default configuration file
    rm /etc/nixos/configuration.nix

    # Clone the repo to a temp folder
    git clone --recurse-submodules -j8 https://github.com/nktfh100/nixos-config /tmp/nixos

    # Copy repo to /etc/nixos
    cp -R /tmp/nixos /etc

    # Move new hardware-configuration file to the appropriate location for this machine
    mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/$PC/

    # Rebuild
    cd /etc/nixos && git add . && sudo nixos-rebuild switch --install-bootloader --flake .#nktfh100-$PC
    ```
* Reset layout
    ```
    gsettings reset org.gnome.desktop.input-sources xkb-options
    gsettings reset org.gnome.desktop.input-sources sources
    ```
