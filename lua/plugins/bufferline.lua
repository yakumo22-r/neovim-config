return 
{
	'akinsho/bufferline.nvim', 
	dependencies = 'nvim-tree/nvim-web-devicons',
	version = "*", 
	config=function()
		require("bufferline").setup{}
		local opt = {noremap = true, silent = true}
		vim.keymap.set("n", "gt", ":BufferLineCyclePrev<CR>", opt)
		vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>", opt)
		vim.keymap.set("n", "<Leader>q", ":bd<CR>", opt)
	end
}
