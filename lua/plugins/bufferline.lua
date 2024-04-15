return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
    config = function()
        local colors = require("ykm22_colors")
        local bufferline = require("bufferline")
        bufferline.setup({
            options = {
                separator_style = "slant",
            },
        })
        local opt = { noremap = true, silent = true }
        vim.keymap.set("n", "gt", ":BufferLineCycleNext<CR>", opt)
        vim.keymap.set("n", "gT", ":BufferLineCyclePrev<CR>", opt)
        vim.keymap.set("n", "g,", ":BufferLineCyclePrev<CR>", opt)
        vim.keymap.set("n", "g.", ":BufferLineCycleNext<CR>", opt)
        vim.keymap.set("n", "<bs>c", ":bdelete %<CR>", opt)
        vim.keymap.set("n", "<bs>a", ":%bdelete<CR>", opt)
        vim.keymap.set("n", "<bs>o", ":%bd|e#|bd#<CR>", opt)

        vim.keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", opt)
        vim.keymap.set("n", "<leader>bq", ":BufferLinePickClose<CR>", opt)
    end,
}
