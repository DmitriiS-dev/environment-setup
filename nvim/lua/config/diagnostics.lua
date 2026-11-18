local diagnostic_signs = {
	Error = "\u{f057} ",
	Warn = "\u{f071} ",
	Hint = "\u{ea61}",
	Info = "\u{f05a}",
}

local function format_diagnostic(diagnostic)
	local message = diagnostic.message:gsub("\n", " ")
	if vim.fn.strchars(message) > 90 then
		return vim.fn.strcharpart(message, 0, 87) .. "..."
	end
	return message
end

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 4,
		source = "if_many",
		format = format_diagnostic,
		current_line = true,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = { severity = vim.diagnostic.severity.ERROR },
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = true,
		style = "minimal",
		max_width = 100,
		max_height = 20,
		wrap = true,
	},
})

require("scrollbar").setup({
	handlers = {
		cursor = false,
		diagnostic = true,
		gitsigns = false,
		handle = true,
		search = false,
	},
	marks = {
		Error = { color = "#f44747" },
		Warn = { color = "#cca700" },
		Info = { color = "#3794ff" },
		Hint = { color = "#89d185" },
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		opts.max_width = opts.max_width or math.floor(vim.o.columns * 0.8)
		opts.max_height = opts.max_height or math.floor(vim.o.lines * 0.6)
		opts.wrap = opts.wrap ~= false
		return orig(contents, syntax, opts, ...)
	end
end
vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
