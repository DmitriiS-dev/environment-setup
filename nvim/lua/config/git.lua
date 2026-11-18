vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })

require("diffview").setup({
	use_icons = true,
	view = {
		merge_tool = {
			layout = "diff3_mixed",
		},
		file_history = {
			win_config = { position = "bottom", height = 16 },
		},
		default = {
			win_config = { position = "bottom", height = 16 },
		},
	},
	file_panel = {
		listing_style = "list",
		win_config = { position = "left", width = 35 },
		log_options = { git = { single_file = true } },
	},
	hooks = {
		diff_buf_read = function()
			vim.opt_local.wrap = false
		end,
	},
})

vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Open Git changes sidebar" })
vim.keymap.set("n", "<leader>gs", "<cmd>DiffviewOpen<cr>", { desc = "Open Git source control sidebar" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Git changes sidebar" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Git file history" })
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "▎", change = "▎", delete = "▎" },
	},
})
vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = "#6a9955" })
vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = "#d7ba7d" })
vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = "#f44747" })

require("mini.git").setup({})

local MiniDiff = require("mini.diff")
vim.keymap.set("n", "]h", function()
	MiniDiff.goto_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	MiniDiff.goto_hunk("prev")
end, { desc = "Prev git hunk" })
vim.keymap.set("n", "<leader>hs", MiniDiff.operator, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hp", function()
	MiniDiff.toggle_overlay()
end, { desc = "Preview diff overlay" })
vim.keymap.set("n", "<leader>hb", function()
	require("mini.git").show_at_cursor()
end, { desc = "Git blame/show" })
