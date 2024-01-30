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

-- plugin lists
require("lazy").setup(
{
	"nvim-lua/plenary.nvim",
	
	-- file explorer
	"nvim-tree/nvim-tree.lua",

	-- icons
	"kyazdani42/nvim-web-devicons",

	-- lualine
	"nvim-lualine/lualine.nvim",
})
