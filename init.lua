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

	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
	{ 'echasnovski/mini.nvim', version = false },

})

require("gruvbox").setup({
	overrides = {

	},
	palette_overrides = {
		dark0_hard = "#1d2021",
		dark0 = "#1e1e1e",
		dark0_soft = "#32302f",
		dark1 = "#3c3836",
		dark2 = "#504945",
		dark3 = "#665c54",
		dark4 = "#7c6f64",
		light0_hard = "#f9f5d7",
		light0 = "#fbf1c7",
		light0_soft = "#f2e5bc",
		light1 = "#ebdbb2",
		light2 = "#d5c4a1",
		light3 = "#bdae93",
		light4 = "#a89984",
		bright_red = "#f86958",
		bright_green = "#c9cc5c",
		bright_yellow = "#fabd2f",
		bright_blue = "#83a598",
		bright_purple = "#d3869b",
		bright_aqua = "#8ec07c",
		bright_orange = "#fe8019",
		neutral_red = "#cc241d",
		neutral_green = "#98971a",
		neutral_yellow = "#d79921",
		neutral_blue = "#458588",
		neutral_purple = "#b16286",
		neutral_aqua = "#689d6a",
		neutral_orange = "#d65d0e",
		faded_red = "#9d0006",
		faded_green = "#79740e",
		faded_yellow = "#b57614",
		faded_blue = "#076678",
		faded_purple = "#8f3f71",
		faded_aqua = "#427b58",
		faded_orange = "#af3a03",
		dark_red_hard = "#792329",
		dark_red = "#722529",
		dark_red_soft = "#7b2c2f",
		light_red_hard = "#fc9690",
		light_red = "#fc9487",
		light_red_soft = "#f78b7f",
		dark_green_hard = "#5a633a",
		dark_green = "#62693e",
		dark_green_soft = "#686d43",
		light_green_hard = "#d3d6a5",
		light_green = "#d5d39b",
		light_green_soft = "#cecb94",
		dark_aqua_hard = "#3e4934",
		dark_aqua = "#49503b",
		dark_aqua_soft = "#525742",
		light_aqua_hard = "#e6e9c1",
		light_aqua = "#e8e5b5",
		light_aqua_soft = "#e1dbac",
		gray = "#928374",
	},
})

vim.o.background = "dark"
vim.cmd([[colorscheme gruvbox]])

require('mini.move').setup()
