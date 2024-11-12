local utils = require("utils")


return {
	{
		"neovim/nvim-lspconfig",
		event = "BufRead",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		keys = {
			{ "K", require("noice.lsp").hover, desc = "Show documentation" },
			{
				"H",
				function()
					vim.diagnostic.open_float({ border = "rounded" })
				end,
				desc = "Show diagnostics",
			},
			{ "<C-k>", vim.lsp.buf.signature_help, desc = "Interactive signature help" },
			{ "<leader>rn", vim.lsp.buf.rename, desc = "Interactive rename" },
			-- { "<leader>rf", vim.lsp.buf.format, desc = "Format code" },
		},
		opts = {
			-- Disable automatic installation of servers
			servers = {
				lua_ls = {
					mason = false,
				},
				nil_ls = {
					mason = false,
				},
				nixd = {
					mason = false,
				},
				ts_ls = {
					mason = false,
				},
			},
		},
		config = function()
			require("mason").setup({ ui = { border = "rounded" } })
			require("mason-lspconfig").setup({
				automatic_installation = false,
				handlers = {
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})

			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup({})
			lspconfig.nil_ls.setup({})
			lspconfig.nixd.setup({
				on_init = function(client, _)
					-- Turn off semantic tokens until they're more consistent
					client.server_capabilities.semanticTokensProvider = nil
				end,
			})
			lspconfig.ts_ls.setup({})

			utils.map({
				{ "<leader>r", group = "refactor", icon = "" },
			})
		end,
	},
	-- {
	-- 	"rachartier/tiny-code-action.nvim",
	-- 	dependencies = {
	-- 		{ "nvim-lua/plenary.nvim" },
	-- 		{ "nvim-telescope/telescope.nvim" },
	-- 	},
	-- 	keys = {
	-- 		{
	-- 			"<leader>a",
	-- 			function() require("tiny-code-action").code_action() end,
	-- 			desc = "Interactive list of code actions",
	-- 		},
	-- 	},
	-- 	event = "LspAttach",
	-- 	opts = {
	-- 		backend = "vim", -- FIXME: delta is not rendering correctly
	-- 		backend_opts = {
	-- 			delta = {
	-- 				header_lines_to_remove = 4,
	-- 				args = { "--features", "nosidebyside" },
	-- 			},
	-- 		},
	-- 	},
	-- }
}
