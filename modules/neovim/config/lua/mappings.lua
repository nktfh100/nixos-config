
local utils = require("utils")

-- TODO

utils.map({
	{"<leader><leader>", ":b#<CR>", desc = "Toggle Between Current And Last Buffer"},
	{"<C-s>", "<ESC> :update <CR>", desc = "Exit Insert Mode And Save File", mode = "i"},
	{"<C-s>", ":update<CR>", desc = "Save File"},
	{"x", '"_x', desc = "Delete Char Without Yanking" },
	-- Move lines and blocks
	{"<A-Up>", ":MoveLine(-1)<CR>", desc = "Move Line Up"},
	{"<A-UP>", ":MoveBlock(-1)<CR>", desc = "Move Block Up", mode = "v"},
	{"<A-Down>", ":MoveLine(1)<CR>", desc = "Move Line Down"},
	{"<A-Down>", ":MoveBlock(1)<CR>", desc = "Move Block Down", mode = "v"},
	{"<A-Right>", ":MoveHChar(1)<CR>", desc = "Move Line Right"},
	{"<A-Right>", ":MoveHBlock(1)<CR>", desc = "Move Block Right", mode = "v"},
	{"<A-Left>", ":MoveHChar(-1)<CR>", desc = "Move Line Left"},
	{"<A-Left>", ":MoveHBlock(-1)<CR>", desc = "Move Block Left", mode = "v"},
})

-- -- Move lines and blocks

-- map("n", "<A-k>", ":MoveLine(-1)<CR>", opts("Move Line Up"))
-- map("v", "<A-k>", ":MoveBlock(-1)<CR>", opts("Move Block Up"))

-- map("n", "<A-j>", ":MoveLine(1)<CR>", opts("Move Line Down"))
-- map("v", "<A-j>", ":MoveBlock(1)<CR>", opts("Move Block Down"))


-- map("n", "<A-l>", ":MoveHChar(1)<CR>", opts("Move Line Right"))
-- map("v", "<A-l>", ":MoveHBlock(1)<CR>", opts("Move Block Right"))

-- map("n", "<A-h>", ":MoveHChar(-1)<CR>", opts("Move Line Left"))
-- map("v", "<A-h>", ":MoveHBlock(-1)<CR>", opts("Move Block Left"))



-- map("n", "<leader>b", ":bp<CR>", opts("Previous Buffer"))

-- map("n", "<leader>w", ":w<CR>", opts("Write Buffer"))

-- map("n", "<leader>q", ":q<CR>", opts("Quit Buffer"))

-- map("n", "<leader>t", ":terminal<CR>", opts("Terminal"))


-- -- Move between splits
-- map("n", "<leader>h", "<C-w>h", opts("Move To The Left Window"))
-- map("n", "<leader>j", "<C-w>j", opts("Move To The Bottom Window"))
-- map("n", "<leader>k", "<C-w>k", opts("Move To The Top Window"))
-- map("n", "<leader>l", "<C-w>l", opts("Move To The Right Window"))

-- -- Paste
-- map("v", "p", '"_dP', opts("Paste Without Yanking")) -- Paste over currently selected text without yanking it
-- map("n", "<C-p>", ":pu<CR>", opts("Paste In Next Line"))



-- -- Open undo tree
-- map("n", "<leader>u", ":UndotreeToggle<CR>", opts("Undo tree"))

-- -- Trouble
-- map("n", "<leader>xx", ":TroubleToggle<CR>", opts("Trouble Toggle"))
-- map("n", "<leader>xw", ":TroubleToggle workspace_diagnostics<CR>", opts("Trouble Workspace Diagnostics"))
-- map("n", "<leader>xd", ":TroubleToggle document_diagnostics<CR>", opts("Trouble Document Diagnostics"))
-- map("n", "<leader>xl", ":TroubleToggle loclist<CR>", opts("Trouble Loclist"))
-- map("n", "<leader>xq", ":TroubleToggle quickfix<CR>", opts("Trouble Quick Fix"))
-- map("n", "gR", ":TroubleToggle lsp_references<CR>", opts("Trouble LSP References"))

-- -- Search box
-- map("n", "<leader>ss", ":SearchBoxMatchAll<CR>", opts("Search: Match All"))
-- map("n", "<leader>sr", ":SearchBoxReplace<CR>", opts("Search: Replace"))
-- map("n", "<leader>se", ":SearchBoxIncSearch<CR>", opts("Search: Incremental"))

-- map("n", "<S-TAB>", utils.remove_tab, opts("Remove Tab"))
