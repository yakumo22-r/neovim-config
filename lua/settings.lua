-- basics
local set = vim.o
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.cmd("nohlsearch")
set.number = true
set.relativenumber = true
set.clipboard = "unnamed"
set.cursorline = true


-- search
set.hlsearsh = true
set.showmatch = true


-- tabs
set.autoindent = true
set.tabstop=4
set.shiftwidth=4
set.softtabstop=4
set.backspace=indent,eol,start
set.smartindent = true
set.list=true
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
