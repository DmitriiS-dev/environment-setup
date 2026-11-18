vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.wrap = false
opt.linebreak = true
opt.scrolloff = 10
opt.sidescrolloff = 10

opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

opt.signcolumn = "yes:2" -- Reserve separate columns for diagnostics and Git.
opt.showmatch = true
opt.cmdheight = 1
opt.completeopt = "menuone,noinsert,noselect"
opt.showmode = false
opt.laststatus = 2 -- Match lualine's per-window status.
opt.pumheight = 10
opt.pumblend = 10
opt.winblend = 0
opt.concealcursor = ""
opt.synmaxcol = 300
opt.fillchars = { eob = " " }

local undodir = vim.fn.expand("~/.vim/undodir")
vim.fn.mkdir(undodir, "p")
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = undodir
opt.updatetime = 300
opt.timeoutlen = 500
opt.ttimeoutlen = 50
opt.autoread = true
opt.autowrite = false

opt.hidden = true
opt.errorbells = false
opt.backspace = "indent,eol,start"
opt.autochdir = false
opt.iskeyword:append("-")
opt.path:append("**")
opt.selection = "inclusive"
opt.mouse = "a"
opt.clipboard:append("unnamedplus")
opt.modifiable = true
require("config.clipboard")

opt.guicursor =
	"n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.splitbelow = true
opt.splitright = true
opt.wildmenu = true
opt.wildmode = "longest:full,full"
opt.diffopt:append("linematch:60")
opt.redrawtime = 10000
opt.maxmempattern = 20000
