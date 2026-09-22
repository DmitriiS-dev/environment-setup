vim.opt.termguicolors = true

-- installed early so it's available before colorscheme() runs below
-- (the rest of the plugin list is installed further down, near PLUGINS)
vim.pack.add({
  "https://github.com/Mofiqul/vscode.nvim"
})

require("vscode").setup()
vim.cmd.colorscheme("vscode")

local function set_transparent() -- set UI component to transparent
	local groups = {
		"Normal",
		"NormalNC",
		"EndOfBuffer",
		"NormalFloat",
		"FloatBorder",
		"SignColumn",
		"StatusLine",
		"StatusLineNC",
		"TabLine",
		"TabLineFill",
		"TabLineSel",
		"ColorColumn",
	}
	for _, g in ipairs(groups) do
		vim.api.nvim_set_hl(0, g, { bg = "none" })
	end
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
end

set_transparent()

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number = true -- line number
vim.opt.relativenumber = true-- relative line numbers
vim.opt.cursorline = true -- highlight current line
vim.opt.wrap = false -- do not wrap code lines by default
vim.opt.linebreak = true
vim.opt.scrolloff = 10 -- keep 10 lines above/below cursor
vim.opt.sidescrolloff = 10 -- keep 10 lines to left/right of cursor

vim.opt.tabstop = 2 -- tabwidth
vim.opt.shiftwidth = 2 -- indent width
vim.opt.softtabstop = 2 -- soft tab stop not tabs on tab/backspace
vim.opt.expandtab = true -- use spaces instead of tabs
vim.opt.smartindent = true -- smart auto-indent
vim.opt.autoindent = true -- copy indent from current line

vim.opt.ignorecase = true -- case insensitive search
vim.opt.smartcase = true -- case sensitive if uppercase in string
vim.opt.hlsearch = true -- highlight search matches
vim.opt.incsearch = true -- show matches as you type

vim.opt.signcolumn = "yes:2" -- keep separate columns for diagnostics and Git changes
vim.opt.showmatch = true -- highlights matching brackets
vim.opt.cmdheight = 1 -- single line command line
vim.opt.completeopt = "menuone,noinsert,noselect" -- completion options
vim.opt.showmode = false -- do not show the mode, instead have it in statusline
vim.opt.laststatus = 2 -- per-window statusline (pairs with lualine's globalstatus = false)
vim.opt.pumheight = 10 -- popup menu height
vim.opt.pumblend = 10 -- popup menu transparency
vim.opt.winblend = 0 -- floating window transparency
vim.opt.concealcursor = "" -- do not hide cursorline in markup
vim.opt.synmaxcol = 300 -- syntax highlighting limit
vim.opt.fillchars = { eob = " " } -- hide "~" on empty lines

local undodir = vim.fn.expand("~/.vim/undodir")
if
	vim.fn.isdirectory(undodir) == 0 -- create undodir if nonexistent
then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.backup = false -- do not create a backup file
vim.opt.writebackup = false -- do not write to a backup file
vim.opt.swapfile = false -- do not create a swapfile
vim.opt.undofile = true -- do create an undo file
vim.opt.undodir = undodir -- set the undo directory
vim.opt.updatetime = 300 -- faster completion
vim.opt.timeoutlen = 500 -- timeout duration
vim.opt.ttimeoutlen = 50 -- key code timeout
vim.opt.autoread = true -- auto-reload changes if outside of neovim
vim.opt.autowrite = false -- do not auto-save

vim.opt.hidden = true -- allow hidden buffers
vim.opt.errorbells = false -- no error sounds
vim.opt.backspace = "indent,eol,start" -- better backspace behaviour
vim.opt.autochdir = false -- do not autochange directories
vim.opt.iskeyword:append("-") -- include - in words
vim.opt.path:append("**") -- include subdirs in search
vim.opt.selection = "inclusive" -- include last char in selection
vim.opt.mouse = "a" -- enable mouse support
vim.opt.clipboard:append("unnamedplus") -- use system clipboard
vim.opt.modifiable = true -- allow buffer modifications

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
end

vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175" -- cursor blinking and settings

-- Folding: requires treesitter available at runtime; safe fallback if not
vim.opt.foldmethod = "expr" -- use expression for folding
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- use treesitter for folding
vim.opt.foldlevel = 99 -- start with all folds open

vim.opt.splitbelow = true -- horizontal splits go below
vim.opt.splitright = true -- vertical splits go right

vim.opt.wildmenu = true -- tab completion
vim.opt.wildmode = "longest:full,full" -- complete longest common match, full completion list, cycle through with Tab
vim.opt.diffopt:append("linematch:60") -- improve diff display
vim.opt.redrawtime = 10000 -- increase neovim redraw tolerance
vim.opt.maxmempattern = 20000 -- increase max memory

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader = " " -- space for leader
vim.g.maplocalleader = " " -- space for localleader

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
vim.keymap.set("i", "<C-v>", '<C-r>+', { desc = "Paste from system clipboard" })

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

-- ============================================================================
-- AUTOCMDS
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Format on save (ONLY real file buffers, ONLY when efm is attached)
vim.api.nvim_create_autocmd("BufWritePre", {
	group = augroup,
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
		-- avoid formatting non-file buffers (helps prevent weird write prompts)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		if not vim.bo[args.buf].modifiable then
			return
		end
		if vim.api.nvim_buf_get_name(args.buf) == "" then
			return
		end

		local has_efm = false
		for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			if c.name == "efm" then
				has_efm = true
				break
			end
		end
		if not has_efm then
			return
		end

		pcall(vim.lsp.buf.format, {
			bufnr = args.buf,
			timeout_ms = 2000,
			filter = function(c)
				return c.name == "efm"
			end,
		})
	end,
})

-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank()
	end,
})

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ============================================================================
-- PLUGINS (vim.pack)
-- ============================================================================
vim.pack.add({
	"https://www.github.com/echasnovski/mini.nvim",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://www.github.com/ibhagwan/fzf-lua",
	"https://www.github.com/nvim-tree/nvim-tree.lua",
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
	"https://github.com/JoosepAlviste/nvim-ts-context-commentstring",
	-- Language Server Protocols
	"https://www.github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/creativenull/efmls-configs-nvim",
	"https://github.com/obsidian-nvim/obsidian.nvim",
	"https://github.com/petertriho/nvim-scrollbar",
	"https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
	"https://github.com/nvimdev/lspsaga.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/folke/zen-mode.nvim",
	{
		-- NOTE: blink.cmp v2 is now the actively developed branch (breaking
		-- changes vs v1). Staying pinned to v1 here deliberately for stability.
		-- Revisit this pin when ready to migrate — v2 requires installing
		-- blink.lib as a native dependency outside vim.pack.
		src = "https://github.com/saghen/blink.cmp",
		version = vim.version.range("1.*"),
	},
	"https://github.com/mrcjkb/rustaceanvim",
})

-- ============================================================================
-- PLUGIN CONFIGS
-- ============================================================================

if vim.fn.has("win32") == 1 and vim.fn.executable("gcc.exe") == 1 then
	vim.env.CC = vim.fn.exepath("gcc.exe")
end

local setup_treesitter = function()
	local treesitter = require("nvim-treesitter")
	treesitter.setup({})
	local ensure_installed = {
		"vim",
		"vimdoc",
		"rust",
		"c",
		"cpp",
		"c_sharp",
		"go",
		"html",
		"css",
		"javascript",
		"json",
		"lua",
		"markdown",
		"python",
		"typescript",
		"vue",
		"svelte",
		"bash",
	}

	local config = require("nvim-treesitter.config")

	local already_installed = config.get_installed()
	local parsers_to_install = {}

	for _, parser in ipairs(ensure_installed) do
		if not vim.tbl_contains(already_installed, parser) then
			table.insert(parsers_to_install, parser)
		end
	end

	if #parsers_to_install > 0 then
		treesitter.install(parsers_to_install)
	end

	local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
	vim.api.nvim_create_autocmd("FileType", {
		group = group,
		callback = function(args)
			if vim.list_contains(config.get_installed(), vim.treesitter.language.get_lang(args.match)) then
				vim.treesitter.start(args.buf)
			end
		end,
	})
end

setup_treesitter()

-- treesitter-aware comment strings (correct comment syntax inside embedded
-- regions, e.g. JS inside JSX/Vue/Svelte) — mini.comment picks this up below
require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

local function get_notes_path()
	if vim.fn.has("win32") == 1 then
		return vim.fn.expand("~/Documents/Notes")
	end

	local os_release = vim.fn.system("cat /etc/os-release")
	if os_release:match("Artix") then
		return vim.fn.expand("~/Documents/Notes")
	elseif os_release:match("Ubuntu") then
		return "/mnt/c/Users/Rad/Documents/Notes"
	end

	error("Unsupported OS: no notes path configured")
end

local function setup_obsidian()
	local notes_path = get_notes_path()
	if vim.fn.isdirectory(notes_path) == 0 then
		vim.fn.mkdir(notes_path, "p")
	end

  require("obsidian").setup({
    legacy_commands = false,
	    workspaces = { { name = "Notes", path = notes_path } },
    picker = { name = "fzf-lua" },
  })

  vim.keymap.set("n", "<leader>nn", function()
    vim.cmd("Obsidian workspace")
    vim.defer_fn(function()
      vim.cmd("Obsidian new")
    end, 500)
  end, { desc = "New note" })
  vim.keymap.set("n", "<leader>nf", "<cmd>Obsidian quick_switch<cr>", { desc = "Find note" })
  vim.keymap.set("n", "<leader>ns", "<cmd>Obsidian search<cr>",       { desc = "Search notes" })
  vim.keymap.set("n", "<leader>nt", "<cmd>Obsidian today<cr>",        { desc = "Today's daily note" })
  vim.keymap.set("n", "<leader>nw", "<cmd>Obsidian workspace<cr>",    { desc = "Switch workspace" })
end

setup_obsidian()

require("nvim-tree").setup({
	view = {
		width = 35,
	},
	filters = {
		dotfiles = false,
	},
	renderer = {
		group_empty = true,
	},
})
vim.keymap.set("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle()
end, { desc = "Toggle NvimTree" })

vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeSignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", { fg = "#2a2a2a", bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

require("fzf-lua").setup({})

vim.keymap.set("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "FZF Files" })
vim.keymap.set("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "FZF Buffers" })
vim.keymap.set("n", "<leader>fh", function()
	require("fzf-lua").help_tags()
end, { desc = "FZF Help Tags" })
vim.keymap.set("n", "<leader>fx", function()
	require("fzf-lua").diagnostics_document()
end, { desc = "FZF Diagnostics Document" })
vim.keymap.set("n", "<leader>fX", function()
	require("fzf-lua").diagnostics_workspace()
end, { desc = "FZF Diagnostics Workspace" })

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

local MiniMap = require("mini.map")
MiniMap.setup({
	integrations = {
		MiniMap.gen_integration.diagnostic({
			error = "DiagnosticFloatingError",
			warn = "DiagnosticFloatingWarn",
			info = "DiagnosticFloatingInfo",
			hint = "DiagnosticFloatingHint",
		}),
		MiniMap.gen_integration.diff(),
		MiniMap.gen_integration.builtin_search(),
	},
	window = {
		side = "right",
		width = 18,
		winblend = 10,
		show_integration_count = true,
	},
})
vim.keymap.set("n", "<leader>mm", MiniMap.toggle, { desc = "Toggle code minimap" })

require("lualine").setup({
	options = {
		theme = "vscode",
		icons_enabled = true,
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		globalstatus = false, -- keep per-window active/inactive styling
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = { { "branch", icon = "\u{e725}" } }, -- nf-dev-git_branch
		lualine_c = { { "filename", path = 0 } },
		lualine_x = {
			"diagnostics",
			function()
				local size = vim.fn.getfsize(vim.fn.expand("%"))
				if size < 0 then
					return ""
				elseif size < 1024 then
					return size .. "B"
				elseif size < 1024 * 1024 then
					return string.format("%.1fK", size / 1024)
				else
					return string.format("%.1fM", size / 1024 / 1024)
				end
			end,
			{ "filetype", icon_only = false },
		},
		lualine_y = { "location" }, -- %l:%c equivalent
		lualine_z = { "progress" }, -- %P equivalent
	},
	inactive_sections = {
		lualine_c = { { "filename", path = 0 } },
		lualine_x = { "filetype" },
	},
})

require("which-key").setup({})
require("which-key").add({
	{ "<leader>f", group = "find" },
	{ "<leader>g", group = "git/LSP" },
	{ "<leader>l", group = "LSP Saga" },
	{ "<leader>x", group = "diagnostics" },
	{ "<leader>z", group = "zen mode" },
	{ "<leader><leader>", desc = "Find files" },
	{ "<leader>fc", desc = "Command palette" },
	{ "<leader>fg", desc = "Search project text" },
	{ "<leader>lp", desc = "Show parameter hints" },
	{ "<leader>gv", desc = "Open Git changes sidebar" },
	{ "<leader>gs", desc = "Open Git source control sidebar" },
	{ "<leader>gq", desc = "Close Git changes sidebar" },
	{ "<leader>gh", desc = "Git file history" },
	{ "g", group = "goto" },
})

require("lspsaga").setup({
	ui = { border = "rounded" },
	lightbulb = { enable = false },
	symbol_in_winbar = { enable = false },
})

require("trouble").setup({
	focus = true,
	win = { position = "bottom", size = 12 },
})

require("zen-mode").setup({
	window = {
		backdrop = 0.85,
		width = 0.85,
		options = { number = false, relativenumber = false },
	},
})

vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Git status" })
vim.keymap.set("n", "<leader>gc", "<cmd>Git commit<cr>", { desc = "Git commit" })
vim.keymap.set("n", "<leader>gp", "<cmd>Git push<cr>", { desc = "Git push" })
vim.keymap.set("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Git log" })

require("diffview").setup({
	use_icons = true,
	view = {
		merge_tool = {
			layout = "diff3_mixed",
		},
		file_history = {
			win_config = { position = "bottom", height = 16 },
		},
		default = {
			win_config = { position = "bottom", height = 16 },
		},
	},
	file_panel = {
		listing_style = "list",
		win_config = { position = "left", width = 35 },
		log_options = { git = { single_file = true } },
	},
	hooks = {
		diff_buf_read = function()
			vim.opt_local.wrap = false
		end,
	},
})

vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Open Git changes sidebar" })
vim.keymap.set("n", "<leader>gs", "<cmd>DiffviewOpen<cr>", { desc = "Open Git source control sidebar" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close Git changes sidebar" })
vim.keymap.set("n", "<leader>gh", "<cmd>DiffviewFileHistory<cr>", { desc = "Git file history" })

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Workspace diagnostics" })
vim.keymap.set("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Document symbols" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })
vim.keymap.set("n", "<leader>zz", "<cmd>ZenMode<cr>", { desc = "Toggle Zen Mode" })

-- restore buffers/window layout per-project on relaunch
require("mini.sessions").setup({})

require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "▎", change = "▎", delete = "▎" },
	},
})
vim.api.nvim_set_hl(0, "MiniDiffSignAdd", { fg = "#6a9955" })
vim.api.nvim_set_hl(0, "MiniDiffSignChange", { fg = "#d7ba7d" })
vim.api.nvim_set_hl(0, "MiniDiffSignDelete", { fg = "#f44747" })

require("mini.git").setup({})

local MiniDiff = require("mini.diff")
vim.keymap.set("n", "]h", function()
	MiniDiff.goto_hunk("next")
end, { desc = "Next git hunk" })
vim.keymap.set("n", "[h", function()
	MiniDiff.goto_hunk("prev")
end, { desc = "Prev git hunk" })
vim.keymap.set("n", "<leader>hs", MiniDiff.operator, { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hp", function()
	MiniDiff.toggle_overlay()
end, { desc = "Preview diff overlay" })
vim.keymap.set("n", "<leader>hb", function()
	require("mini.git").show_at_cursor()
end, { desc = "Git blame/show" })

require("mason").setup({})
require("mason-tool-installer").setup({
	ensure_installed = {
		"basedpyright",
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

-- ============================================================================
-- LSP, Linting, Formatting & Completion
-- ============================================================================
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
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
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

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump_to_single_result = true })
	end, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set({ "n", "i" }, "<A-Enter>", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	vim.keymap.set("n", "<leader>lf", "<cmd>Lspsaga finder<cr>", opts)
	vim.keymap.set("n", "<leader>lh", "<cmd>Lspsaga hover_doc<cr>", opts)
	vim.keymap.set("n", "<leader>lp", vim.lsp.buf.signature_help, opts)
	vim.keymap.set("n", "<leader>la", "<cmd>Lspsaga code_action<cr>", opts)
	vim.keymap.set("n", "<leader>lr", "<cmd>Lspsaga rename<cr>", opts)
	vim.keymap.set("n", "<leader>lo", "<cmd>Lspsaga outline<cr>", opts)
	vim.keymap.set("n", "<leader>ld", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

require("blink.cmp").setup({
	keymap = {
		preset = "none",
		["<C-Space>"] = { "show", "hide" },
		["<CR>"] = { "accept", "fallback" },
		["<C-j>"] = { "select_next", "fallback" },
		["<C-k>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<Up>"] = { "select_prev", "fallback" },
		["<Tab>"] = { "snippet_forward", "fallback" },
		["<S-Tab>"] = { "snippet_backward", "fallback" },
	},
	appearance = { nerd_font_variant = "mono" },
	completion = {
		menu = {
			auto_show = function()
				return vim.bo.filetype ~= "markdown"
			end,
		},
	},
	-- signature help while typing function calls (was previously unset)
	signature = { enabled = true },
	sources = { default = { "lsp", "path", "buffer", "snippets" } },
	-- snippets now use blink's native engine — LuaSnip dependency removed
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { download = true },
	},
})

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
		local ok, view = pcall(function()
			return require("diffview.lib").get_current_view()
		end)
		local context = ok and view and view.adapter and view.adapter.ctx
		if context then
			return context.toplevel or context.dir
		end
	end

	local start_dir = buffer_name ~= "" and (vim.fn.isdirectory(buffer_name) == 1 and buffer_name or vim.fs.dirname(buffer_name))
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
			or (params.workspaceFolders and params.workspaceFolders[1] and vim.uri_to_fname(params.workspaceFolders[1].uri))
			or (params.rootUri and vim.uri_to_fname(params.rootUri))
			or vim.fn.getcwd()
		local venv = find_python_venv(root)
		if not venv then
			return
		end

		local python_bin = vim.fn.has("win32") == 1
			and vim.fs.joinpath(venv, "Scripts", "python.exe")
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

do
	local luacheck = require("efmls-configs.linters.luacheck")
	local stylua = require("efmls-configs.formatters.stylua")

	local ruff_lint = require("efmls-configs.linters.ruff")
	local ruff_format = require("efmls-configs.formatters.ruff")

	local prettier_d = require("efmls-configs.formatters.prettier_d")
	local eslint_d = require("efmls-configs.linters.eslint_d")

	local fixjson = require("efmls-configs.formatters.fixjson")

	local shellcheck = require("efmls-configs.linters.shellcheck")
	local shfmt = require("efmls-configs.formatters.shfmt")

	local cpplint = require("efmls-configs.linters.cpplint")
	local clangfmt = require("efmls-configs.formatters.clang_format")

	local go_revive = require("efmls-configs.linters.go_revive")
	local gofumpt = require("efmls-configs.formatters.gofumpt")

	vim.lsp.config("efm", {
		filetypes = {
			"c",
			"cpp",
			"css",
			"go",
			"html",
			"javascript",
			"javascriptreact",
			"json",
			"jsonc",
			"lua",
			"markdown",
			"python",
			"sh",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
		},
		init_options = { documentFormatting = true },
		settings = {
			languages = {
				c = { clangfmt, cpplint },
				go = { gofumpt, go_revive },
				cpp = { clangfmt, cpplint },
				css = { prettier_d },
				html = { prettier_d },
				javascript = { eslint_d, prettier_d },
				javascriptreact = { eslint_d, prettier_d },
				json = { eslint_d, fixjson },
				jsonc = { eslint_d, fixjson },
				lua = { luacheck, stylua },
				markdown = { prettier_d },
				python = { ruff_lint, ruff_format },
				sh = { shellcheck, shfmt },
				typescript = { eslint_d, prettier_d },
				typescriptreact = { eslint_d, prettier_d },
				vue = { eslint_d, prettier_d },
				svelte = { eslint_d, prettier_d },
			},
		},
	})
end

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

-- ============================================================================
-- TERMINAL
-- ============================================================================
vim.api.nvim_create_autocmd("TermClose", {
	group = augroup,
	callback = function()
		if vim.v.event.status == 0 then
			vim.api.nvim_buf_delete(0, {})
		end
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = augroup,
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
vim.keymap.set("n", "<C-`>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("n", "<C-@>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("n", "<C-'>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-`>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-@>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<C-'>", toggle_bottom_terminal, { silent = true, desc = "Toggle bottom terminal" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Terminal normal mode" })
vim.keymap.set("t", "<C-q>", toggle_bottom_terminal, { silent = true, desc = "Close bottom terminal" })
