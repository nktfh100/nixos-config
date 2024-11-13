{ pkgs, unstable, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/nvim
    ln -Ts /etc/nixos/modules/neovim/config /home/nktfh100/.config/nvim
  '';

  environment.systemPackages = with pkgs; [
    unstable.neovim

    xclip # Clipboard integration

    lua5_1

    # Formatters
    nixfmt-rfc-style # Nix
    black # Python
    prettierd # JS/TS
    shfmt # Shell
    stylua # Lua

    # LSP
    lua-language-server
    nixd
    nil
    nodePackages_latest.typescript-language-server

    # Tools
    cmake
    # cargo
    fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
    fzf
    gcc
    git
    gnumake
    nodejs
    sqlite
    tree-sitter
    luarocks
    # Required by telescope
    ripgrep
    fd
  ];

}