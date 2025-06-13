return {
    "romgrk/barbar.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
    },

    init = function()
        vim.g.barbar_auto_setup = false
    end,

    config = function()
        require("barbar").setup({
            animation = false,
        })

        local map = vim.api.nvim_set_keymap
        local opts = { noremap = true, silent = true }
        map("n", "<C-h>", "<Cmd>BufferPrevious<CR>", opts)
        map("n", "<C-l>", "<Cmd>BufferNext<CR>", opts)

        map("n", "<A-h>", "<Cmd>BufferMovePrevious<CR>", opts)
        map("n", "<A-l>", "<Cmd>BufferMoveNext<CR>", opts)

        bufu = require("bufutils")
        vim.keymap.set("n", "<bs>c", bufu.close_curr_buffer, opts)
        map("n", "<bs>o", "<Cmd>BufferCloseAllButCurrent<CR>", opts)

        map('n', '<leader>bg',   '<Cmd>BufferPick<CR>', opts)
        map('n', '<leader>bd', '<Cmd>BufferPickDelete<CR>', opts)
    end,
}
