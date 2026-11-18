local function find_python_venv(path)
	local directory = vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
	while directory and directory ~= "" do
		for _, name in ipairs({ ".venv", "venv", "env", ".env" }) do
			local candidate = vim.fs.joinpath(directory, name)
			if vim.fn.isdirectory(candidate) == 1 then
				return candidate
			end
		end

		local parent = vim.fs.dirname(directory)
		if parent == directory then
			break
		end
		directory = parent
	end
end

local python_root_markers = {
	"pyproject.toml",
	"setup.py",
	"setup.cfg",
	"requirements.txt",
	"Pipfile",
	"pyrightconfig.json",
	".git",
}

local function find_python_root(bufnr)
	local buffer_name = vim.api.nvim_buf_get_name(bufnr)
	if buffer_name:match("^diffview://") then
		local view = require("diffview.lib").get_current_view()
		local context = view and view.adapter and view.adapter.ctx
		if context then
			return context.toplevel or context.dir
		end
	end

	local start_dir = buffer_name ~= ""
			and (vim.fn.isdirectory(buffer_name) == 1 and buffer_name or vim.fs.dirname(buffer_name))
		or vim.fn.getcwd()
	local marker = vim.fs.find(python_root_markers, { path = start_dir, upward = true })[1]
	return marker and vim.fs.dirname(marker) or vim.fn.getcwd()
end

vim.lsp.config("basedpyright", {
	root_dir = function(bufnr, on_dir)
		on_dir(find_python_root(bufnr))
	end,
	before_init = function(params, config)
		local root = config.root_dir
			or (params.workspaceFolders and params.workspaceFolders[1] and vim.uri_to_fname(
				params.workspaceFolders[1].uri
			))
			or (params.rootUri and vim.uri_to_fname(params.rootUri))
			or vim.fn.getcwd()
		local venv = find_python_venv(root)
		if not venv then
			return
		end

		local python_bin = vim.fn.has("win32") == 1 and vim.fs.joinpath(venv, "Scripts", "python.exe")
			or vim.fs.joinpath(venv, "bin", "python")
		if vim.fn.executable(python_bin) ~= 1 then
			return
		end

		config.settings = config.settings or {}
		config.settings.python = config.settings.python or {}
		config.settings.python.pythonPath = python_bin
		config.settings.python.venvPath = vim.fs.dirname(venv)
		config.settings.python.venv = vim.fs.basename(venv)
		config.settings.basedpyright = config.settings.basedpyright or {}
		config.settings.basedpyright.analysis = vim.tbl_extend("force", config.settings.basedpyright.analysis or {}, {
			autoSearchPaths = true,
			useLibraryCodeForTypes = true,
		})
		config.cmd_env = vim.tbl_extend("force", config.cmd_env or {}, {
			VIRTUAL_ENV = venv,
		})
	end,
})
