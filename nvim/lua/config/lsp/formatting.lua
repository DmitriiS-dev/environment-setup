local function formatter(name)
	return require("efmls-configs.formatters." .. name)
end

local function linter(name)
	return require("efmls-configs.linters." .. name)
end

local prettier = formatter("prettier_d")
local javascript = { linter("eslint_d"), prettier }
local json = { linter("eslint_d"), formatter("fixjson") }
local cpp = { formatter("clang_format"), linter("cpplint") }
local languages = {
	c = cpp,
	cpp = cpp,
	go = { formatter("gofumpt"), linter("go_revive") },
	css = { prettier },
	html = { prettier },
	javascript = javascript,
	javascriptreact = javascript,
	json = json,
	jsonc = json,
	lua = { linter("luacheck"), formatter("stylua") },
	markdown = { prettier },
	python = { linter("ruff"), formatter("ruff") },
	sh = { formatter("shfmt") }, -- Bash Language Server owns ShellCheck diagnostics.
	typescript = javascript,
	typescriptreact = javascript,
	vue = javascript,
	svelte = javascript,
}

vim.lsp.config("efm", {
	filetypes = vim.tbl_keys(languages),
	init_options = { documentFormatting = true },
	settings = { languages = languages },
})

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("UserFormatting", { clear = true }),
	pattern = {
		"*.lua",
		"*.py",
		"*.go",
		"*.js",
		"*.jsx",
		"*.ts",
		"*.tsx",
		"*.json",
		"*.css",
		"*.scss",
		"*.html",
		"*.sh",
		"*.bash",
		"*.zsh",
		"*.c",
		"*.cpp",
		"*.h",
		"*.hpp",
	},
	callback = function(args)
		local buffer = vim.bo[args.buf]
		if buffer.buftype ~= "" or not buffer.modifiable or vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end
		if #vim.lsp.get_clients({ bufnr = args.buf, name = "efm" }) == 0 then
			return
		end
		local ok, err = pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(client)
				return client.name == "efm"
			end,
		})
		if not ok then
			vim.notify("Format on save failed: " .. tostring(err), vim.log.levels.ERROR)
		end
	end,
})
