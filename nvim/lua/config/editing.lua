require("mini.ai").setup({})
require("mini.comment").setup({
	options = {
		custom_commentstring = function()
			return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
		end,
	},
})
require("mini.move").setup({})
require("mini.surround").setup({})
require("mini.cursorword").setup({})
require("mini.indentscope").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
require("mini.notify").setup({})
require("mini.icons").setup({})
require("mini.tabline").setup({
	show_icons = true,
	format = function(buf_id, label)
		local modified = vim.bo[buf_id].modified and " +" or ""
		return " " .. label .. modified .. " "
	end,
})

vim.keymap.set("n", "<leader>bd", function()
	require("mini.bufremove").delete(0)
end, { desc = "Close current file tab" })
vim.keymap.set("n", "]b", ":bnext<CR>", { desc = "Next open file tab" })
vim.keymap.set("n", "[b", ":bprevious<CR>", { desc = "Previous open file tab" })

require("mini.sessions").setup({})
