local function on_attach(bufnr)
    local api = require("nvim-tree.api")

    local function set_key_opts(k, v, desc, mode)
        vim.keymap.set(mode or "n", k, v, { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true })
    end

    local function delKey(k)
        vim.keymap.del("n", k, { buffer = bufnr })
    end

    -- default mappings
    api.config.mappings.default_on_attach(bufnr)

    delKey("<C-k>")
    delKey("<C-t>")
    delKey("]e")
    delKey("[e")

    delKey("<C-r>")
    delKey("<C-v>")
    delKey("<C-x>")
    delKey("<C-]>")
    delKey("<C-e>")

    set_key_opts("=", api.tree.change_root_to_node, "CD")
    set_key_opts("?", api.tree.toggle_help, "Help")

    -- custom mappings
    set_key_opts("?", api.tree.toggle_help, "Help")

    -- for other plugins
    set_key_opts("<leader>pp", function ()
        local node = api.tree.get_node_under_cursor()
        if node then
            print("Absolute path: " .. node.absolute_path)
            print("Relative path: " .. vim.fn.fnamemodify(node.absolute_path, ":."))
        end
    end, "SFTP Operation")
end

return {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
        local nvimtree = require("nvim-tree")
        -- vim.g.loaded = 1
        vim.g.loaded_netrw = 1
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
            git = {
                enable = false,
            },
            on_attach = on_attach,
            sync_root_with_cwd = true,
            respect_buf_cwd = true,
        })

        vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
    end,
}
