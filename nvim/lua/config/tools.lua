require("mason").setup({})

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("UserTools", { clear = true }),
	pattern = "MasonToolsStartingInstall",
	once = true,
	callback = function()
		local missing = {}
		for _, tools in ipairs({
			{ commands = { "git" }, label = "git" },
			{ commands = { "rg" }, label = "ripgrep (project search)" },
			{ commands = { "fzf" }, label = "fzf (file picker)" },
			{ commands = { "node" }, label = "Node.js (JavaScript tools)" },
			{ commands = { "npm" }, label = "npm (JavaScript tools)" },
			{ commands = { "python3", "python" }, label = "Python (BasedPyright, clang-format)" },
			{ commands = { "gcc", "clang" }, label = "C compiler (Treesitter parsers)" },
			{ commands = { "unzip" }, label = "unzip (StyLua, clangd)" },
			{ commands = { "go" }, label = "Go (gofumpt)" },
		}) do
			local available = vim.iter(tools.commands):any(function(command)
				return vim.fn.executable(command) == 1
			end)
			if not available then
				table.insert(missing, tools.label)
			end
		end
		if #missing > 0 then
			vim.schedule(function()
				vim.notify(
					"Missing tool prerequisites:\n  " .. table.concat(missing, "\n  "),
					vim.log.levels.WARN,
					{ title = "Environment Warning" }
				)
			end)
		end
	end,
})

require("mason-tool-installer").setup({
	ensure_installed = {
		"bash-language-server",
		"shellcheck",
		"basedpyright",
		"clangd",
		"efm",
		"stylua",
		"ruff",
		"prettierd",
		"shfmt",
		"clang-format",
		"gofumpt",
		"tree-sitter-cli",
	},
	run_on_start = true,
})
