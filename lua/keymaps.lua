local opt = {noremap = true, silent = true}
vim.g.mapleader = " "
vim.keymap.set ("n", "<C-h>", "<C-w>h", opt)
vim.keymap.set ("n", "<C-l>", "<C-w>l", opt)
vim.keymap.set ("n", "<C-j>", "<C-w>j", opt)
vim.keymap.set ("n", "<C-k>", "<C-w>k", opt)
vim.keymap.set ("n", "<Leader>v", "<C-w>v", opt)
vim.keymap.set ("n", "<Leader>s", "<C-w>s", opt)

vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], {noremap=true, expr = true})
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], {noremap=true, expr = true})

vim.keymap.set("n", "<Leader><CR>", ":nohlsearch<CR>", opt)

-- quick q! wq w
vim.keymap.set("n", "W", ":w<CR>", opt)
vim.keymap.set("n", "Q", ":q!<CR>", opt)

-- quick movement
vim.keymap.set("n", "H", "0", opt)
vim.keymap.set("n", "L", "$", opt)

-- move text
vim.keymap.set("n", "<", "<<", opt)
vim.keymap.set("n", ">", ">>", opt)
vim.keymap.set("v", "<", "<gv", opt)
vim.keymap.set("v", ">", ">gv", opt)

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opt)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opt)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opt)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opt)

