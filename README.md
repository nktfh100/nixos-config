
# NixOS Config

My personal NixOS configuration files I use for all my linux machines.

Lucifer theme was entirely designed by Astra.

# What I Use

- OS: [NixOS](https://nixos.org)
- Color Scheme: Lucifer (modified Catppuccin) or Catppuccin Macchiato
- WM: [Hyprland](https://hyprland.org/)
- Lock Screen: [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) with a custom Lucifer lock screen
- Desktop Shell / Status Bar: [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell) with both themes
- Application Launcher: [Rofi](https://github.com/davatorium/rofi)
- Terminal: [Kitty](https://sw.kovidgoyal.net/kitty)
- Shell: [Bash](https://www.gnu.org/software/bash)
- Editors: [Neovim](https://neovim.io), [VS Code](https://code.visualstudio.com/)
- Browser: [Firefox](https://www.mozilla.org/en-US/firefox)
- Smarter cd: [zoxide](https://github.com/ajeetdsouza/zoxide)
- Secret Management: [sops-nix](https://github.com/Mic92/sops-nix)

# Secrets (sops-nix)

## Setup

1. **Generate an age key**:
   ```bash
   mkdir -p ~/.age
   nix-shell -p age --run "age-keygen -o ~/.age/key.txt"
   ```

2. **Get your age public key**:
   ```bash
   age-keygen -y ~/.age/key.txt
   ```

3. **Edit secrets**:
   ```bash
   nix-shell -p sops --run "sops secrets.yaml"
   ```

4. **The secrets are available at**:
   - `/run/secrets/<secret-name>`

## Adding New Secrets

1. Edit `secrets.yaml`:
   ```bash
   nix-shell -p sops --run "sops secrets.yaml"
   ```

2. Add your secret

3. Rebuild

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
    cp -R /tmp/nixos/. /etc/nixos/

    # Move new hardware-configuration file to the appropriate location for this machine
    mv /etc/nixos/hardware-configuration.nix /etc/nixos/hosts/$PC/

    # Rebuild
    sudo nixos-rebuild switch --install-bootloader --flake "path:/etc/nixos#nktfh100-$PC"
    ```
