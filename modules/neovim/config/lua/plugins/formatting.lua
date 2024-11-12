return {
    'stevearc/conform.nvim',
    opts = {},
    config = function()
        require("conform").setup({
            formatters_by_ft = {
                javascript = { "prettierd" },
				typescript = { "prettierd" },
                typescriptreact = { "prettierd" },
                javascriptreact = { "prettierd" },
				json = { "prettierd" },
				yaml = { "prettierd" },
				html = { "prettierd" },

				lua = { "stylua" },
				nix = { "nixfmt" },
				python = { "black" },
				sh = { "shfmt" },
            },
        })

        vim.api.nvim_create_autocmd("BufWritePre", {
            pattern = "*",
            callback = function(args)
                if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
					return
				end
                require("conform").format({ bufnr = args.buf })
            end,
        })

        vim.api.nvim_create_user_command("FormatDisable", function(args)
            if args.bang then
                vim.b.disable_autoformat = true
            else
                vim.g.disable_autoformat = true
            end
        end, {
            desc = "Disable autoformat-on-save",
            bang = true,
        })

        vim.api.nvim_create_user_command("FormatEnable", function()
            vim.b.disable_autoformat = false
            vim.g.disable_autoformat = false
        end, {
            desc = "Re-enable autoformat-on-save",
        })
    end,
}