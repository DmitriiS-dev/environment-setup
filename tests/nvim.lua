local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
vim.opt.runtimepath:prepend(root .. "/nvim")

local configs = {}
vim.lsp.config = function(name, config)
	configs[name] = config
end
for _, category in ipairs({ "formatters", "linters" }) do
	for _, name in ipairs({
		"prettier_d",
		"eslint_d",
		"fixjson",
		"clang_format",
		"cpplint",
		"gofumpt",
		"go_revive",
		"luacheck",
		"stylua",
		"ruff",
		"shellcheck",
		"shfmt",
	}) do
		package.preload["efmls-configs." .. category .. "." .. name] = function()
			return { name = name }
		end
	end
end

require("config.lsp.formatting")
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_name(buf, "format-test.py")
local attached = false
local formatted, notified = 0, 0
vim.lsp.get_clients = function(filter)
	assert(filter.bufnr == buf and filter.name == "efm")
	return attached and { { name = "efm" } } or {}
end
vim.lsp.buf.format = function(opts)
	assert(opts.bufnr == buf)
	assert(opts.filter({ name = "efm" }) and not opts.filter({ name = "basedpyright" }))
	formatted = formatted + 1
end
vim.notify = function(_, level)
	assert(level == vim.log.levels.ERROR)
	notified = notified + 1
end
local function write_event()
	vim.api.nvim_exec_autocmds("BufWritePre", { buffer = buf })
end
write_event()
assert(formatted == 0, "Formatted without EFM")
attached = true
write_event()
assert(formatted == 1, "Did not format a real file with EFM")
vim.bo[buf].buftype = "nofile"
write_event()
vim.bo[buf].buftype = ""
vim.bo[buf].modifiable = false
write_event()
vim.bo[buf].modifiable = true
assert(formatted == 1, "Formatted a special or unmodifiable buffer")
vim.lsp.buf.format = function()
	error("formatter failed")
end
write_event()
assert(notified == 1, "Formatting error was hidden")
print("PASS: format-on-save guards and visible errors")

require("config.lsp.python")
local python = configs.basedpyright
local tmp = vim.fn.tempname()
local venv = tmp .. "/.venv"
local executable = vim.fn.has("win32") == 1 and venv .. "/Scripts/python.exe" or venv .. "/bin/python"
vim.fn.mkdir(vim.fs.dirname(executable), "p")
vim.fn.mkdir(tmp .. "/src", "p")
vim.fn.writefile({}, tmp .. "/pyproject.toml")
vim.fn.writefile({ "#!/bin/sh" }, executable)
assert(vim.uv.fs_chmod(executable, 493))
vim.api.nvim_buf_set_name(buf, tmp .. "/src/example.py")
local detected
python.root_dir(buf, function(path)
	detected = path
end)
assert(detected == tmp, "Python project root detection changed")
local config = { root_dir = tmp }
python.before_init({}, config)
assert(config.settings.python.pythonPath == executable, "Project virtualenv was not selected")
assert(config.cmd_env.VIRTUAL_ENV == venv)

package.preload["diffview.lib"] = function()
	return {
		get_current_view = function()
			return { adapter = { ctx = { toplevel = tmp } } }
		end,
	}
end
vim.api.nvim_buf_set_name(buf, "diffview://test/example.py")
python.root_dir(buf, function(path)
	detected = path
end)
assert(detected == tmp, "Diffview lost its Python project root")
vim.fn.delete(tmp, "rf")
print("PASS: Python project, virtualenv and Diffview roots")
vim.cmd("qa!")
