require("config.lsp.keymaps")

vim.lsp.config["*"] = {
	capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})

require("config.lsp.python")

vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("omnisharp", {})

vim.g.rustaceanvim = {
	server = {
		capabilities = require("blink.cmp").get_lsp_capabilities(),
	},
}

require("config.lsp.formatting")

vim.lsp.enable({
	"lua_ls",
	"basedpyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
	"omnisharp",
	"efm",
})
