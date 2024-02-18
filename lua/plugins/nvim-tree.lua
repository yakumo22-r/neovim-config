return {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        local nvimtree = require("nvim-tree")
        vim.g.loaded = 1
        vim.g.loaded_netrwPlugin = 1

        nvimtree.setup({
            renderer = {
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "→",
                            arrow_open = "↓",
                        },
                    },
                },
            },
            actions = {
                open_file = {
                    window_picker = {
                        enable = true,
                    },
                },
            },
        })

        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
}
