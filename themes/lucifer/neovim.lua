local available, catppuccin = pcall(require, "catppuccin")
if available then
  catppuccin.setup(vim.tbl_deep_extend("force", catppuccin.options, {
    transparent_background = false,
    term_colors = true,
    color_overrides = { macchiato = {
      crust = "#1a131a", mantle = "#292029", base = "#201820",
      surface0 = "#352831", surface1 = "#42303c", surface2 = "#634555",
      overlay0 = "#b7a6b0", overlay1 = "#c1aeb8", overlay2 = "#d0bdc6",
      subtext0 = "#d0bdc6", subtext1 = "#e2d2d9", text = "#f7edf0",
      rosewater = "#f4dbd6", flamingo = "#f0c6c6", pink = "#f5bde6",
      mauve = "#c6a0f6", red = "#ff6470", maroon = "#ff5364",
      peach = "#f5a97f", yellow = "#eed49f", green = "#a6da95",
      teal = "#8bd5ca", sky = "#91d7e3", sapphire = "#7dc4e4",
      blue = "#8aadf4", lavender = "#b7bdf8",
    } },
  }))
  vim.cmd.colorscheme("catppuccin-macchiato")
end

local colors = {
  Normal = { fg = "#f7edf0", bg = "#201820" },
  NormalFloat = { fg = "#f7edf0", bg = "#292029" },
  FloatBorder = { fg = "#ff5364", bg = "#292029" },
  Comment = { fg = "#c1aeb8", italic = true },
  String = { fg = "#a6da95" },
  Function = { fg = "#eed49f" },
  Keyword = { fg = "#c6a0f6" },
  Type = { fg = "#8aadf4" },
  Number = { fg = "#f5a97f" },
  Identifier = { fg = "#f7edf0" },
  Statement = { fg = "#c6a0f6" },
  Special = { fg = "#8bd5ca" },
  Visual = { bg = "#76162b" },
  Search = { fg = "#201820", bg = "#ff5364" },
  CursorLine = { bg = "#352831" },
  CursorLineNr = { fg = "#ff5364", bold = true },
  LineNr = { fg = "#b7a6b0" },
  WinSeparator = { fg = "#634555" },
  StatusLine = { fg = "#ff5364", bg = "#292029" },
  TabLineSel = { fg = "#201820", bg = "#ff5364", bold = true },
  TabLine = { fg = "#d0bdc6", bg = "#292029" },
  TabLineFill = { bg = "#201820" },
  Pmenu = { fg = "#f7edf0", bg = "#292029" },
  PmenuSel = { fg = "#201820", bg = "#ff5364" },
  DiagnosticError = { fg = "#ff6470" },
  DiagnosticWarn = { fg = "#eed49f" },
  DiagnosticInfo = { fg = "#8aadf4" },
  DiagnosticHint = { fg = "#8bd5ca" },
}
local function apply()
  for group, value in pairs(colors) do
    vim.api.nvim_set_hl(0, group, value)
  end
end
vim.api.nvim_create_autocmd("ColorScheme", { callback = apply })
apply()
local function statusline()
  local loaded, lualine = pcall(require, "lualine")
  if loaded then
    local base = {
      a = { fg = "#201820", bg = "#ff5364", gui = "bold" },
      b = { fg = "#f7edf0", bg = "#42303c" },
      c = { fg = "#d0bdc6", bg = "#292029" },
    }
    lualine.setup({ options = { theme = {
      normal = base, insert = base, visual = base, replace = base,
      command = base, inactive = base,
    } } })
  end
end
vim.api.nvim_create_autocmd("User", { pattern = "VeryLazy", callback = statusline, once = true })
