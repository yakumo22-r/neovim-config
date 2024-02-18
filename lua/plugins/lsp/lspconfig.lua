return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        "williamboman/mason.nvim",
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local keybindings = require("plugins.lsp.tools.lsp-keybindings")
        local nohighlight = function(client, bufnr)
            -- no highlight
            client.server_capabilities.semanticTokensProvider = nil
        end

        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        -- (not in youtube nvim video)
        local signs = {
            Error = " ",
            Warn = " ",
            Hint = "󰦩 ",
            Info = "",
        }

        vim.diagnostic.config({
            virtual_text = false,
            severity_sort = true,
            signs = true,
            update_in_insert = false,
            underline = false,
            float = {
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = false,
            filetypes = { "lua", "lua.txt" },
            settings = { -- custom settings for lua
                Lua = {
                    runtime = {
                        path = {
                            "?.lua",
                            "?.lua.txt",
                            "?/init.lua",
                            "?/init.lua.txt",
                        },
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        -- make language server aware of runtime files
                        library = {
                            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                            [vim.fn.stdpath("config") .. "/lua"] = true,
                        },
                    },
                },
            },
        })

        lspconfig["neocmake"].setup({
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = true,
        })

        lspconfig["clangd"].setup({
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = true,
        })
    end,
}
