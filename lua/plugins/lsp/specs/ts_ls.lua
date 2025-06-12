local lsp_base = require("plugins.lsp.tools.lsp_base")

local spec_ts_ls = lsp_base.new_entity({"javascript", "javascriptreact", "typescript", "typescriptreact"})

---@type integer?
local ts_ls_client = nil

---@param bufnr integer
function spec_ts_ls:attach_buf(bufnr)
    if not ts_ls_client then
        ts_ls_client = vim.lsp.start({
            name = "ts_ls",
            cmd = { lsp_base.cmd("typescript-language-server"), "--stdio" },
            -- root_dir = function ()
            --     return vim.fn.getcwd()
            -- end,
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            root_markers = { "package.json", "tsconfig.json", ".git" },
            -- root_markers = {".git"},
            capabilities = self.capabilities,
            on_init = function(client)
                vim.lsp.buf_attach_client(bufnr, ts_ls_client)
            end,
            on_attach = function(client, bufnr2)
                self.keybindings(client, bufnr2)
                -- no highlight
                client.server_capabilities.semanticTokensProvider = nil
            end,
            single_file_support = true,
            settings = {
                diagnostics = {
                    ignoredCodes = { 7043, 7044, 7045, 7046, 7047, 7048, 7049, 7050 },
                },
            },
        })
    else
        vim.lsp.buf_attach_client(bufnr, ts_ls_client)
    end
end

return spec_ts_ls
