vim.opt.termguicolors = true

-- Load the theme before other plugins create their highlights.
vim.pack.add({
	"https://github.com/Mofiqul/vscode.nvim",
})

require("vscode").setup({
	group_overrides = {
		["@variable.python"] = { link = "Normal" },
		["@variable.builtin.python"] = { link = "Normal" },
		["@variable.parameter.python"] = { link = "Normal" },
		["@variable.member.python"] = { link = "Normal" },
		["@module.python"] = { link = "Normal" },
	},
})
vim.cmd.colorscheme("vscode")

for _, group in ipairs({
	"Normal",
	"NormalNC",
	"EndOfBuffer",
	"NormalFloat",
	"FloatBorder",
	"SignColumn",
	"StatusLine",
	"StatusLineNC",
	"TabLine",
	"TabLineFill",
	"TabLineSel",
	"ColorColumn",
}) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
