local set = vim.o
set.number = true
set.relativenumber = true
set.clipboard = "unnamed"
set.tabstop=4
set.shiftwidth=4
set.softtabstop=4
set.autoindent = true
set.backspace=indent,eol,start
-- highlight after copy
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
	pattern = { "*" },
	callback = function()
		vim.highlight.on_yank({
			timeout = 400,
		})
	end,
})

-- keybindings
local opt = {noremap = true, silent = true}
vim.g.mapleader = " "
vim.keymap.set ("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set ("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set ("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set ("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set ("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set ("n", "<Leader>s", "<C-w>s", opt)

vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], {noremap=true, expr = true})
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], {noremap=true, expr = true})

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	print("install lazy.nvim...")
	print(vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"git@github.com:folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	}))
	print("install lazy.nvim done.")
end
vim.opt.rtp:prepend(lazypath)


require("lazy").setup(
{

	{ 'echasnovski/mini.nvim', version = false },

})
require('ykm22_colors').setup()

require('mini.move').setup()
