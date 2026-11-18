local MiniMap = require("mini.map")
MiniMap.setup({
	integrations = {
		MiniMap.gen_integration.diagnostic({
			error = "DiagnosticFloatingError",
			warn = "DiagnosticFloatingWarn",
			info = "DiagnosticFloatingInfo",
			hint = "DiagnosticFloatingHint",
		}),
		MiniMap.gen_integration.diff(),
		MiniMap.gen_integration.builtin_search(),
	},
	window = {
		side = "right",
		width = 18,
		winblend = 10,
		show_integration_count = true,
	},
})
vim.keymap.set("n", "<leader>mm", MiniMap.toggle, { desc = "Toggle code minimap" })

require("lualine").setup({
	options = {
		theme = "vscode",
		icons_enabled = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = false, -- keep per-window active/inactive styling
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "branch", icon = "\u{e725}" } }, -- nf-dev-git_branch
		lualine_c = { { "filename", path = 0 } },
		lualine_x = {
			"diagnostics",
			function()
				local size = vim.fn.getfsize(vim.fn.expand("%"))
				if size < 0 then
					return ""
				elseif size < 1024 then
					return size .. "B"
				elseif size < 1024 * 1024 then
					return string.format("%.1fK", size / 1024)
				else
					return string.format("%.1fM", size / 1024 / 1024)
				end
			end,
			{ "filetype", icon_only = false },
		},
		lualine_y = { "location" }, -- %l:%c equivalent
		lualine_z = { "progress" }, -- %P equivalent
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 0 } },
		lualine_x = { "filetype" },
	},
})

require("which-key").setup({})
require("which-key").add({
	{ "<leader>f", group = "find" },
	{ "<leader>g", group = "git/LSP" },
	{ "<leader>l", group = "LSP Saga" },
	{ "<leader>x", group = "diagnostics" },
	{ "<leader>z", group = "zen mode" },
	{ "<leader><leader>", desc = "Find files" },
	{ "<leader>fc", desc = "Command palette" },
	{ "<leader>fg", desc = "Search project text" },
	{ "<leader>lp", desc = "Show parameter hints" },
	{ "<leader>gv", desc = "Open Git changes sidebar" },
	{ "<leader>gs", desc = "Open Git source control sidebar" },
	{ "<leader>gq", desc = "Close Git changes sidebar" },
	{ "<leader>gh", desc = "Git file history" },
	{ "g", group = "goto" },
})

require("lspsaga").setup({
	ui = { border = "rounded" },
	lightbulb = { enable = false },
	symbol_in_winbar = { enable = false },
})

require("trouble").setup({
	focus = true,
	win = { position = "bottom", size = 12 },
})

require("zen-mode").setup({
	window = {
		backdrop = 0.85,
		width = 0.85,
		options = { number = false, relativenumber = false },
	},
})
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })
vim.keymap.set("n", "<leader>zz", "<cmd>ZenMode<cr>", { desc = "Toggle Zen Mode" })
