if vim.fn.has("win32") == 1 and vim.fn.executable("win32yank.exe") == 1 then
	vim.g.clipboard = {
		name = "win32yank",
		copy = {
			["+"] = { "win32yank.exe", "-i", "--crlf" },
			["*"] = { "win32yank.exe", "-i", "--crlf" },
		},
		paste = {
			["+"] = { "win32yank.exe", "-o", "--lf" },
			["*"] = { "win32yank.exe", "-o", "--lf" },
		},
		cache_enabled = 0,
	}
elseif vim.fn.has("wsl") == 1 and vim.fn.executable("clip.exe") == 1 then
	vim.g.clipboard = {
		name = "wslclip",
		copy = {
			["+"] = { "clip.exe" },
			["*"] = { "clip.exe" },
		},
		paste = {
			["+"] = { "powershell.exe", "-noprofile", "-command", "Get-Clipboard" },
			["*"] = { "powershell.exe", "-noprofile", "-command", "Get-Clipboard" },
		},
		cache_enabled = 0,
	}
elseif vim.fn.filereadable("/run/.containerenv") == 1 or vim.fn.filereadable("/.dockerenv") == 1 then
	local osc52 = require("vim.ui.clipboard.osc52")
	local copy, paste = {}, {}
	for _, register in ipairs({ "+", "*" }) do
		local cached_lines, cached_type = {}, "v"
		local copy_to_terminal = osc52.copy(register)
		copy[register] = function(lines, regtype)
			cached_lines, cached_type = vim.deepcopy(lines), regtype
			copy_to_terminal(lines)
		end
		-- Terminal clipboard reads are often blocked; paste Windows text via the terminal.
		paste[register] = function()
			return { vim.deepcopy(cached_lines), cached_type }
		end
	end
	vim.g.clipboard = {
		name = "OSC 52 (copy only; terminal paste for host text)",
		copy = copy,
		paste = paste,
		cache_enabled = 0,
	}
elseif vim.env.SSH_TTY or vim.env.SSH_CLIENT or vim.env.SSH_CONNECTION then
	-- Remote SSH session: use OSC 52 so yanked text copies to the local terminal.
	if vim.ui and vim.ui.clipboard and vim.ui.clipboard.osc52 then
		local osc52 = require("vim.ui.clipboard.osc52")
		vim.g.clipboard = {
			name = "OSC 52",
			copy = {
				["+"] = osc52.copy("+"),
				["*"] = osc52.copy("*"),
			},
			paste = {
				["+"] = osc52.paste("+"),
				["*"] = osc52.paste("*"),
			},
		}
	end
end
