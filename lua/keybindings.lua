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
vim.keymap.set("n", "W", ":w<CR>", opts)
vim.keymap.set("n", "Q", ":q!<CR>", opts)

-- quick movement
vim.keymap.set("n", "J", "5j", opts)
vim.keymap.set("n", "K", "5k", opts)
vim.keymap.set("n", "H", "0", opts)
vim.keymap.set("n", "L", "$", opts)

-- move text
vim.keymap.set("n", "<", "<<", opts)
vim.keymap.set("n", ">", ">>", opts)
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opts)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opts)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

--tabs
vim.keymap.set("n", "tn", ":tabnew<CR>", opt)
