return {
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
	-- Greeter
	{
		'goolord/alpha-nvim',
		config = function ()
			require'alpha'.setup(require'alpha.themes.dashboard'.config)

			local alphaDashboard = require("alpha.themes.dashboard")

			alphaDashboard.section.buttons.val = {
				alphaDashboard.button("f", "󰈞  Find file",require("telescope.builtin").find_files),
				alphaDashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
				alphaDashboard.button("r", "󰷊  Recently used files", require("telescope.builtin").oldfiles),
				alphaDashboard.button("t", "  Find text", require("telescope.builtin").live_grep),
				alphaDashboard.button("q", "󰩈  Quit Neovim", ":qa<CR>"),
			}

			require("alpha").setup(alphaDashboard.config)
		end
	},
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
	-- Status line
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
	-- Indent lines
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		---@module "ibl"
		---@type ibl.config
		opts = {},
	},
	-- Transparent background
	{
		"xiyaowong/transparent.nvim",
		lazy = false,
		config = function()
			require("transparent").setup({
				groups = {
					'Normal', 'NormalNC', 'Comment', 'Constant', 'Special', 'Identifier',
					'Statement', 'PreProc', 'Type', 'Underlined', 'Todo', 'String', 'Function',
					'Conditional', 'Repeat', 'Operator', 'Structure', 'LineNr', 'NonText',
					'SignColumn', 'CursorLineNr', 'EndOfBuffer',
				},
			})
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