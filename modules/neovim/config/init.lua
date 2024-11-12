
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy_init")
require("settings")

-- require("mappings")

-- Set theme
vim.cmd("syntax enable")
vim.cmd("syntax on")
vim.cmd("colorscheme catppuccin-macchiato")
