local group = vim.api.nvim_create_augroup("UserTerminal", { clear = true })

vim.api.nvim_create_autocmd("TermClose", {
	group = group,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = group,
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		vim.opt_local.signcolumn = "no"
	end,
})

local terminal_state = { buf = nil, win = nil }

local function terminal_command()
	if vim.fn.has("win32") == 1 then
		for _, shell in ipairs({ "pwsh.exe", "powershell.exe" }) do
			if vim.fn.executable(shell) == 1 then
				return { vim.fn.exepath(shell), "-NoLogo" }
			end
		end
	elseif vim.fn.executable("fish") == 1 then
		return { vim.fn.exepath("fish") }
	end
	return vim.o.shell
end

local function toggle_bottom_terminal()
	if terminal_state.win and vim.api.nvim_win_is_valid(terminal_state.win) then
		vim.api.nvim_win_close(terminal_state.win, false)
		terminal_state.win = nil
		return
	end

	vim.cmd("botright 15split")
	if not terminal_state.buf or not vim.api.nvim_buf_is_valid(terminal_state.buf) then
		vim.cmd("enew")
		terminal_state.buf = vim.api.nvim_get_current_buf()
		vim.bo[terminal_state.buf].bufhidden = "hide"
		vim.fn.termopen(terminal_command())
	else
		vim.api.nvim_win_set_buf(0, terminal_state.buf)
	end

	terminal_state.win = vim.api.nvim_get_current_win()
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
for _, key in ipairs({ "<C-`>", "<C-@>", "<C-'>" }) do
	vim.keymap.set({ "n", "t" }, key, toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
end
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Terminal normal mode" })
vim.keymap.set("t", "<C-q>", toggle_bottom_terminal, { silent = true, desc = "Close bottom terminal" })
