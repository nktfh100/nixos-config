{ pkgs, unstable, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/nvim
    ln -Ts /etc/nixos/modules/neovim/config /home/nktfh100/.config/nvim
  '';

  environment.systemPackages = with pkgs; [
    neovim
    wl-clipboard

    lua
    lua-language-server
    go

    isort # Sort imports
    nodePackages.prettier # JS/TS formatter
    stylua # Lua formatter

    # Required by telescope
    ripgrep
    fd
  ];
}
