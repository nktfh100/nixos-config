local map = require("utils").map

return {
	{
		"folke/which-key.nvim",
		dependencies = {
			"echasnovski/mini.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			preset = "helix",
		},
		keys = {
			{
				"<leader>h",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
	-- Jump to any character
	{
		"smoka7/hop.nvim",
		version = "v2.7.*",
		lazy = false,
		opts = {
			keys = "etovxqpdygfblzhckisuran",
		},
		keys = {
			{
				"f",
				function()
					require("hop").hint_char1()
				end,
				desc = "Hop",
			},
			{
				"t",
				function()
					require("hop").hop_pattern()
				end,
				desc = "Hop Pattern Matching",
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	-- Move lines and blocks
	{
		"fedepujol/move.nvim",
		opts = {
			char = {
				enable = true,
			},
		},
	},
	{
		"Wansmer/treesj",
		keys = { {
			"<space>rm",
			function()
				require("treesj").toggle()
			end,
			desc = "Toggle Spread",
		} },
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		config = function()
			require("treesj").setup({})
		end,
	},
	-- Easy commenting
	{
		"numToStr/Comment.nvim",
		opts = {
			mappings = {
				basic = true,
				extra = false,
			},
		},
	},
	-- Auto close buffers
	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = { retirementAgeMins = 15 },
	},
	-- Search and replace
	{
		"VonHeikemen/searchbox.nvim",
		dependencies = { "MunifTanjim/nui.nvim" },
		keys = {
			{
				"<leader>ss",
				function()
					require("searchbox").match_all()
				end,
				desc = "Search",
			},
			{
				"<leader>sr",
				function()
					require("searchbox").replace()
				end,
				desc = "Search And Replace",
			},
		},
		init = function()
			map({ "<leader>s", group = "Search", icon = "" })
		end,
	},
	-- Time tracking
	{ "wakatime/vim-wakatime", lazy = false },
}
