require("settings")
require("plugins")
require("mappings")

-- Set theme
vim.cmd("syntax enable")
vim.cmd("syntax on")
vim.o.t_Co = 256
vim.cmd("colorscheme catppuccin-macchiato")