-- _G.Telescope = {}

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff" },
        { "<leader>fs" },
        { "<leader>fb" },
        { "<leader>fg" },
        { "<leader>fr" },
        { "<leader>fp" },
        { "<leader>fd" },
        { "<leader>gc" },
        { "<leader>gC" },
        { "<leader>gs" },
    },
    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")

        local tb = require("telescope.builtin")

        telescope.setup({
            defaults = {
                path_display = { "truncate " },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                        ["<C-j>"] = actions.move_selection_next, -- move to next result
                    },
                    n = {
                        ["<C-j>"] = actions.cycle_history_next, -- next history
                        ["<C-k>"] = actions.cycle_history_prev, -- prev history
                    },
                },
                vimgrep_arguments = {
                    "rg",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--smart-case",
                    "--trim", -- add this value
                },
            },
            pickers = {
                buffers = {
                    mappings = {
                        n = {
                            ["d"] = actions.delete_buffer + actions.move_to_top,
                        },
                    },
                },
                find_files = {
                    -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                    find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" },
                },
            },
        })

        telescope.load_extension("fzf")

        vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Fuzzy find files in cwd" })
        vim.keymap.set("n", "<leader>fs", tb.live_grep, { desc = "Find string in cwd" })
        vim.keymap.set("n", "<leader>fb", tb.buffers, { desc = "Find open buffers" })
        vim.keymap.set("n", "<leader>fg", tb.buffers, { desc = "Find string in git files " })
        vim.keymap.set("n", "<leader>fr", tb.resume, { desc = "resume last search" })
        vim.keymap.set("n", "<leader>fp", tb.pickers, { desc = "show all pickers" })
        vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "show all lsp diagnotics" })
        vim.keymap.set("n", "<leader>gc", tb.git_bcommits, { desc = "show all lsp diagnotics" })
        vim.keymap.set("n", "<leader>gC", tb.git_commits, { desc = "show all lsp diagnotics" })
        vim.keymap.set("n", "<leader>gs", tb.git_status, { desc = "show all lsp diagnotics" })
    end,
}
