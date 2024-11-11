return {
    -- Syntax highlighting
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "lua", "vim", "vimdoc", "javascript", "html", "python", "typescript"
            },
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}