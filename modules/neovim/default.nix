{ pkgs, unstable, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/nvim
    ln -Ts /etc/nixos/modules/neovim/config /home/nktfh100/.config/nvim
  '';

  environment.systemPackages = with pkgs; [
    neovim-unwrapped
    wl-clipboard

    lua
    lua-language-server
    nixfmt # Format nix

    nodePackages.prettier # JS/TS formatter

    gcc # C compiler

    # Required by telescope
    ripgrep
    fd
  ];
}
