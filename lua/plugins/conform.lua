return {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    config = function()
        local conform = require("conform")
        conform.setup({
            formatters_by_ft = {
                c = { "clang_format" },
                lua = { "stylua" },
                json = { "prettierd" },
                javascript = { "prettierd" },
                typescript = { "prettierd" },
                vue = { "prettierd" },
                css = { "prettierd" },
                scss = { "prettierd" },
                less = { "prettierd" },
                html = { "prettierd" },
                sh = { "shfmt" },
            },
        })

        if User.formatrc.prettier then
            conform.formatters.prettierd = {
                env = {
                    PRETTIERD_DEFAULT_CONFIG = User.formatrc.prettier,
                },
            }
        end

        conform.formatters.shfmt = {
            inherit = false,
            command = "shfmt",
            args = { "-i", "4", "-filename", "$FILENAME" },
        }

        vim.keymap.set("n", "<leader>FM", function()
            require("conform").format({
                async = true,
                lsp_fallback = true,
            })
        end)

        vim.keymap.set("v", "<leader>fm", function()
            require("conform").format({
                async = true,
                lsp_fallback = true,
            })
        end)

        vim.keymap.set("n", "<leader>fm", function()
            vim.api.nvim_feedkeys("V", "n", false)
            vim.schedule(function()
                require("conform").format({
                    async = true,
                    lsp_fallback = true,
                },function ()
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
                end)
            end)
        end)
    end,
}
