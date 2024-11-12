return {
    -- Syntax highlighting
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "lua", "vim", "vimdoc", "javascript", "html", "python", "typescript", "bash"
            },
            auto_install = true,
            sync_install = true,
            highlight = { enable = true },
            indent = { enable = true },
        })
    end
}