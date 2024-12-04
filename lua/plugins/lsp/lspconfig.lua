return {
    "neovim/nvim-lspconfig",
    -- event = { "VeryLazy" },
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

        local function lua_ignores(fname)
            local util = require("lspconfig/util")
            local path = util.path
            if fname:match("xmake.lua$") then
                return nil -- ignore
            else
                return util.find_git_ancestor(fname) or util.path.dirname(fname)
            end
        end

        -- 自定义 LSP 引用处理函数，将路径转换为相对路径
        -- local base_handler = vim.lsp.handlers["textDocument/references"]
        -- vim.lsp.handlers["textDocument/references"] = function(err, result, ctx, config)
        --     if result then
        --         for _, res in ipairs(result) do
        --             res.uri = make_paths_relative(res.uri)
        --         end
        --     end
        --     print(result)
        --     base_handler(err, result, ctx, config)
        -- end

        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
            root_dir = lua_ignores,
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = true,
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
                        disable = { "lowercase-global","trailing-space","empty-block" },
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

        lspconfig["clangd"].setup({
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = true,
        })

        lspconfig["ts_ls"].setup({
            capabilities = capabilities,
            on_attach = keybindings,
            single_file_support = true,
            settings = { -- custom settings for ts
                diagnostics = {
                    ignoredCodes = { 7043, 7044, 7045, 7046, 7047, 7048, 7049, 7050 },
                },
            },
        })

        local original_open_floating_preview = vim.lsp.util.open_floating_preview
        vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
            local cols = ykm22_cols
            opts = opts or {}
            opts.border = "rounded" -- 设置边框样式: 'single', 'double', 'rounded', 'solid', 'shadow'
            -- 自定义背景颜色
            -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1e1e1e' })
            vim.api.nvim_set_hl(0, "FloatBorder", { fg = cols.flamingo })
            return original_open_floating_preview(contents, syntax, opts, ...)
        end

        -- if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
        --     vim.api.nvim_create_autocmd("BufEnter", {
        --       callback = function()
        --         local bufname = vim.api.nvim_buf_get_name(0)
        --         local relpath = vim.fn.fnamemodify(bufname, ":.")
        --         if bufname ~= relpath then
        --           vim.api.nvim_buf_set_name(0, relpath)
        --         end
        --       end
        --     })
        -- end

    end,
}
