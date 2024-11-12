{ pkgs, unstable, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/nvim
    ln -Ts /etc/nixos/modules/neovim/config /home/nktfh100/.config/nvim
  '';

  environment.systemPackages = with pkgs; [
    unstable.neovim

    wl-clipboard # Clipboard integration

    # Formatters
    nixfmt-rfc-style # Nix
    black # Python
    prettierd # JS/TS
    shfmt # Shell
    stylua # Lua

    # LSP
    lua-language-server
    # my.logseqlsp
    nixd
    nil

    lua

    # Tools
    cmake
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
