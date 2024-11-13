local function opts(desc)
	return { desc = desc, noremap = true, silent = true, nowait = true }
end

local function map(...) return require("which-key").add(...) end

-- Remove a single tab from the current line
local function remove_tab()
	local line = vim.api.nvim_get_current_line()

	-- Remove a tab character (\t) from the line
	local updated_line = string.gsub(line, "\t", "", 1)

	vim.api.nvim_set_current_line(updated_line)
end

-- Function to open file and close nvim tree
function open_or_edit(api, edit_type)
	return function()
		local node = api.tree.get_node_under_cursor()

		local open_func
		if edit_type == "normal" then
			open_func = api.node.open.edit
		elseif edit_type == "vertical" then
			open_func = api.node.open.vertical
		elseif edit_type == "horizontal" then
			open_func = api.node.open.horizontal
		elseif edit_type == "tab" then
			open_func = api.node.open.tab
		end

		if node.nodes ~= nil then
			open_func() -- expand or collapse folder
		else
			open_func()
			api.tree.close()
		end
	end
end

return {
	opts = opts,
	map = map,
	remove_tab = remove_tab,
	open_or_edit = open_or_edit,
}