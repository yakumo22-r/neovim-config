local bufferline = {}

function close_curr_buffer()
    local curr_buf = vim.api.nvim_get_current_buf()
    vim.cmd("BufferLineCyclePrev")
    vim.cmd("bdelete "..curr_buf)
end

return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
    config = function()
        local colors = require("ykm22_colors")
        bufferline = require("bufferline")
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
        vim.keymap.set("n", "<bs>c", close_curr_buffer, opt)
        vim.keymap.set("n", "<bs>o", ":BufferLineCloseOthers<CR>", opt)
        vim.keymap.set("n", "<bs>r", ":BufferLineCloseRight<CR>", opt)
        vim.keymap.set("n", "<bs>l", ":BufferLineCloseLeft<CR>", opt)

        vim.keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", opt)
        vim.keymap.set("n", "<leader>bq", ":BufferLinePickClose<CR>", opt)
    end,
}
