-- basics
-- make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- force sh-files with zsh-shebang to still get sh as filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
	},
}

-- highlight after copy
vim.api.nvim_create_autocmd({ "textyankpost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({
            timeout = 400,
        })
    end,
})

-- presistent undo
vim.cmd("set undofile")
vim.opt.undodir = vim.fn.stdpath("config") .. "/.tmp/undo"

-- disable automatic commenting on newline
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "*" },
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})
