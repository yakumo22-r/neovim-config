local lsp_base = require("plugins.lsp.tools.lsp_base")

local LspSetting = {}

local keybindings = require("plugins.lsp.tools.lsp-keybindings")
local nohighlight = function(client, bufnr)
    client.server_capabilities.semanticTokensProvider = nil
end

local signs = {
    Error = " ",
    Warn = " ",
    Hint = "󰦩 ",
    Info = "",
}

local spec_lua_ls = require("plugins.lsp.specs.lua_ls")
spec_lua_ls:init()

local spec_ts_ls = require("plugins.lsp.specs.ts_ls")
spec_ts_ls:init()

local function lsp_clangd(capabilities)
    vim.lsp.config.clangd = {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", ".git" },
        on_attach = function(client, bufnr)
            keybindings(client, bufnr)
            nohighlight(client, bufnr)
        end,
        capabilities = capabilities,
        single_file_support = true,
    }
end

-- local function lsp_ts_ls(capabilities)
--     vim.lsp.config.ts_ls = {
--         cmd = { "typescript-language-server", "--stdio" },
--         filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
--         root_markers = { "package.json", "tsconfig.json", ".git" },
--         on_attach = function(client, bufnr)
--             keybindings(client, bufnr)
--             nohighlight(client, bufnr)
--         end,
--         capabilities = capabilities,
--         single_file_support = true,
--         settings = {
--             diagnostics = {
--                 ignoredCodes = { 7043, 7044, 7045, 7046, 7047, 7048, 7049, 7050 },
--             },
--         },
--     }
-- end

function LspSetting.Init()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    -- Enable autocompletion capabilities
    local capabilities = cmp_nvim_lsp.default_capabilities()

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

    lsp_clangd(capabilities)

    spec_lua_ls:set_enable(capabilities, keybindings)
    spec_ts_ls:set_enable(capabilities,keybindings)

    -- Custom :LspInfo command to display LSP client info
    vim.api.nvim_create_user_command("LspInfo", function()
      local bufnr = vim.api.nvim_get_current_buf()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      if #clients == 0 then
        vim.notify("No LSP clients attached to this buffer", vim.log.levels.INFO)
        return
      end

      local info = {}
      for _, client in ipairs(clients) do
        table.insert(info, string.format("LSP Client: %s (ID: %d)", client.name, client.id))
        table.insert(info, string.format("  Root Dir: %s", client.config.root_dir or "N/A"))
        table.insert(info, string.format("  Status: %s", client.is_stopped() and "Stopped" or "Running"))
        -- table.insert(info, string.format("  Capabilities: %s", vim.inspect(client.server_capabilities, { depth = 1 })))
        table.insert(info, "")
      end
      vim.notify(table.concat(info, "\n"), vim.log.levels.INFO)
    end, { desc = "Display LSP client info for current buffer" })
end

return LspSetting
