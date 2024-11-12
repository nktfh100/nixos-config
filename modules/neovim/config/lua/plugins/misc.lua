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
				"<leader><leader>",
				function()
					require("which-key").show({ global = true })
				end,
				desc = "Buffer Local Keymaps (which-key)",
			},
		},
	},
}
