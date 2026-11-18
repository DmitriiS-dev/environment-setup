local function project_root()
	local buffer_name = vim.api.nvim_buf_get_name(0)
	local start_dir = buffer_name ~= "" and vim.fs.dirname(buffer_name) or vim.fn.getcwd()
	local git_dir = vim.fs.find(".git", { path = start_dir, upward = true })[1]
	return git_dir and vim.fs.dirname(git_dir) or vim.fn.getcwd()
end

-- better movement in wrapped text
vim.keymap.set("n", "j", function()
	return vim.v.count == 0 and "gj" or "j"
end, { expr = true, silent = true, desc = "Down (wrap-aware)" })
vim.keymap.set("n", "k", function()
	return vim.v.count == 0 and "gk" or "k"
end, { expr = true, silent = true, desc = "Up (wrap-aware)" })

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-f>", "/", { desc = "Find in current file" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
vim.keymap.set({ "n", "v" }, "<leader>x", '"_d', { desc = "Delete without yanking" })
vim.keymap.set("x", "<C-c>", '"+y', { desc = "Copy selection" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("x", "<C-v>", '"_d"+P', { desc = "Replace selection from clipboard" })
vim.keymap.set("i", "<C-v>", "<C-r>+", { desc = "Paste from system clipboard" })

vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split window vertically" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split window horizontally" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left and reselect" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right and reselect" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

vim.keymap.set("n", "<leader>pa", function() -- show file path
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end, { desc = "Copy full file path" })

vim.keymap.set("n", "<leader>td", function()
	vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle diagnostics" })

vim.keymap.set("n", "<C-b>", function()
	require("nvim-tree.api").tree.toggle()
end)

vim.keymap.set("n", "<C-s>", "<cmd>w<cr>")
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<cr>a")

vim.keymap.set("n", "<leader><leader>", function()
	require("fzf-lua").files()
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fc", function()
	require("fzf-lua").commands()
end, { desc = "Command palette" })

vim.keymap.set("n", "gF", "gF", { desc = "Open file under cursor at line" })
vim.keymap.set("n", "<leader>go", "gf", { desc = "Open file under cursor" })
vim.keymap.set("n", "<C-o>", "<C-o>", { desc = "Jump back" })
vim.keymap.set("n", "<leader>lp", vim.lsp.buf.signature_help, { desc = "Show parameter hints" })

vim.keymap.set("n", "gf", function()
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
		if client:supports_method("textDocument/definition", 0) then
			vim.lsp.buf.definition()
			return
		end
	end
	vim.cmd("normal! gf")
end, { desc = "Go to symbol definition or file" })

vim.keymap.set("n", "<leader>fg", function()
	require("fzf-lua").live_grep({ cwd = project_root() })
end, { desc = "Search project text" })
