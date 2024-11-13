return {
	-- UI overhaul
    {
        "folke/noice.nvim",
        lazy = false,
        opts = {},
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
	},
	-- Theme
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000, lazy = false, init = function()
		require("catppuccin").setup({
			integrations = {
				cmp = true,
				gitsigns = true,
				treesitter = true,
				notify = true,
				alpha = true,
				hop = true,
				mason = true,
				neotree = true,
				noice = true,
				treesitter = true,
				lsp_trouble = true,
				which_key = true,
				barbecue = {
					dim_dirname = true,
					bold_basename = true,
					dim_context = false,
					alt_background = false,
				},
				native_lsp = {
					enabled = true,
				},
			}
		})
	end
	},
	-- {
	-- 	'goolord/alpha-nvim',
	-- 	config = function ()
	-- 		require'alpha'.setup(require'alpha.themes.dashboard'.config)
	-- 	end
	-- },
	-- Highlight TODO comments
    {
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
        opts = {};
	},
	-- VSCode like winbar
	{
		"utilyre/barbecue.nvim",
		name = "barbecue",
		version = "v1.2.*",
		dependencies = {
			"SmiteshP/nvim-navic",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {},
		init = function()
			require("barbecue").setup {
				theme = "catppuccin-macchiato",
			}
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		lazy = false,
		init = function()
			require('lualine').setup {
				options = {
					theme = "catppuccin"
				}
			}
		end,

	},
    -- Icons
	{
		"echasnovski/mini.icons",
		opts = {},
		lazy = true,
		specs = {
			{ "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				-- needed since it will be false when loading and mini will fail
				package.loaded["nvim-web-devicons"] = {}
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}