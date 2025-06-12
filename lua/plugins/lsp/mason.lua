local LspSetting = require("plugins.lsp.tools.lsp_setting")
return {
    "williamboman/mason.nvim",
    event = { "VeryLazy" },
    dependencies = {
        -- "williamboman/mason-lspconfig.nvim",
        -- "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        -- import mason
        local mason = require("mason")

        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
            ensure_installed = {
                -- lsp servers
                "lua_ls",
                "clangd",
                "ts_ls",

                -- formatters
                "stylua", -- lua formatter
                "prettierd",
                "clang-format",
                "shfmt",
            }
        })

        LspSetting.Init()
    end,
}
