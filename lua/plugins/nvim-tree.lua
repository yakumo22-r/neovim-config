local function on_attach(bufnr)
    local api = require("nvim-tree.api")

    local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    -- custom mappings

    vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
    vim.keymap.set("n", "<leader>=", api.tree.change_root_to_node, opts("Help"))
end

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
            on_attach = on_attach,
        })
    end,
}
