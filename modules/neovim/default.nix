{ pkgs, ... }:

{
  system.activationScripts.neovimSymLink.text = ''
    rm -f -r /home/nktfh100/.config/nvim
    ln -Ts /etc/nixos/modules/neovim/neovim-config /home/nktfh100/.config/nvim
  '';

  environment.systemPackages = with pkgs; [
    (neovim.override { withNodeJs = true; })

    lua5_1

    # Formatters
    nixfmt-rfc-style # Nix
    black # Python
    prettierd # JS/TS
    shfmt # Shell
    stylua # Lua

    # LSP
    lua-language-server
    emmet-language-server
    nodePackages_latest.typescript-language-server
    typos-lsp
    prettier
    # nodePackages."@prisma/language-server"
    tailwindcss-language-server
    vscode-langservers-extracted # HTML/CSS/JSON/ESLint
    nixd

    tree-sitter

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
