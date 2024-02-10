local opt = { noremap = true, silent = true }
vim.g.mapleader = " "
-- sheild
vim.keymap.set("n", "z", "", opt)
vim.keymap.set("n", "c", "", opt)
vim.keymap.set("n", "q", "", opt)

-- window
vim.keymap.set("n", "<Leader>h", "<C-w>h", opt)
vim.keymap.set("n", "<Leader>l", "<C-w>l", opt)
vim.keymap.set("n", "<Leader>j", "<C-w>j", opt)
vim.keymap.set("n", "<Leader>k", "<C-w>k", opt)

vim.keymap.set("n", "<leader>sk", ":set nosplitbelow<CR>:split<CR>", opt)
vim.keymap.set("n", "<leader>sj", ":set splitbelow<CR>:split<CR>", opt)
vim.keymap.set("n", "<leader>sh", ":set nosplitright<CR>:vsplit<CR>", opt)
vim.keymap.set("n", "<leader>sl", ":set splitright<CR>:vsplit<CR>", opt)

vim.keymap.set("n", "<leader>srh", "<C-w>b<C-w>K", opt)
vim.keymap.set("n", "<leader>srv", "<C-w>b<C-w>H", opt)

-- move line
vim.keymap.set("n", "<A-up>", ":res +2<cr>", opt)
vim.keymap.set("n", "<A-down>", ":res -2<cr>", opt)
vim.keymap.set("n", "<A-left>", ":vertical resize -2<cr>", opt)
vim.keymap.set("n", "<A-right>", ":vertical resize +2<cr>", opt)

-- hide search highlight
vim.keymap.set({ "v", "n" }, "<Leader><CR>", ":nohlsearch<CR>", opt)

-- quick q! wq w
vim.keymap.set("n", "W", ":w<CR>", opt)
vim.keymap.set("n", "Q", ":q!<CR>", opt)

-- move
vim.keymap.set("n", "j", [[v:count ? 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count ? 'k' : 'gk']], { noremap = true, expr = true })

-- quick movement
vim.keymap.set({ "v", "n" }, "L", "$", opt)
vim.keymap.set({ "v", "n" }, "H", "^", opt)
-- move text
vim.keymap.set("n", "<", "<<", opt)
vim.keymap.set("n", ">", ">>", opt)
vim.keymap.set("v", "<", "<gv", opt)
vim.keymap.set("v", ">", ">gv", opt)

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", opt)
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", opt)
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", opt)
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", opt)

-- copy
vim.keymap.set({ "n", "v" }, "d", '"_d')
vim.keymap.set({ "n", "v" }, "s", '"_s')
vim.keymap.set("v", "p", '"_dp')
vim.keymap.set("v", "P", '"_dP')

-- ({["'
vim.keymap.set("n", "<leader>{", "a{}<Esc>i", opt)
vim.keymap.set("n", "<leader>[", "a[]<Esc>i", opt)
vim.keymap.set("n", "<leader>(", "a()<Esc>i", opt)
vim.keymap.set("n", "<leader><", "a<><Esc>i", opt)
vim.keymap.set("n", '<leader>"', 'a"<Esc>i', opt)
vim.keymap.set("n", "<leader>'", "a'<Esc>i", opt)
