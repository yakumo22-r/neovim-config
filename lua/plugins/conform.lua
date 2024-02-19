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
            args = {"-i", "4", "-filename", "$FILENAME"},
        }
        local opt = { noremap = true, silent = true }
        vim.keymap.set({ "n", "v" }, "=", "", {
            noremap = true,
            silent = true,
            callback = function()
                require("conform").format({
                    async = true,
                    lsp_fallback = true,
                })
            end,
        })
    end,
}
