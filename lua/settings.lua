-- basics
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamed"
vim.opt.cursorline = true


-- search
vim.opt.hlsearch = true
vim.opt.showmatch = true


-- tabs
vim.opt.autoindent = true
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.softtabstop=4
vim.opt.backspace="indent,eol,start"
vim.opt.smartindent = true
vim.opt.list=true

-- highlight after copy
vim.api.nvim_create_autocmd({ "textyankpost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 400,
		})
	end,
})
vim.cmd([[set iskeyword+=-]])


vim.opt.scrolloff = 2

-- presistent undo
vim.cmd 'set undofile'
vim.opt.undodir = vim.fn.stdpath('config') .. '/.tmp/undo'

-- disable automatic commenting on newline
vim.api.nvim_create_autocmd({"FileType"},{
	pattern = {"*"},
	command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

