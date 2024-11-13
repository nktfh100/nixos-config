return {
	{
		"folke/which-key.nvim",
		dependencies = {
			"echasnovski/mini.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		opts = {
			preset = "modern", -- helix ?
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
	{
		'smoka7/hop.nvim',
		version = "v2.7.*",
		lazy = false,
		opts = {
			keys = 'etovxqpdygfblzhckisuran'
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
		}
	},
	{'wakatime/vim-wakatime', lazy = false}
}
