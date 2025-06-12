local lsp_base = require("plugins.lsp.tools.lsp_base")

local spec_clangd = lsp_base.new_entity({ "c", "cpp", "objc", "objcpp" })

---@type integer?
local clangd_client = nil

---@param bufnr integer
function spec_clangd:attach_buf(bufnr)
    if not clangd_client then
        clangd_client = vim.lsp.start({
            name = "clangd",
            cmd = { lsp_base.cmd("clangd") },
            filetypes = { "c", "cpp", "objc", "objcpp" },
            root_markers = { "compile_commands.json", ".git" },
            capabilities = self.capabilities,
            on_init = function(client)
                vim.lsp.buf_attach_client(bufnr, clangd_client)
            end,
            on_attach = function(client, bufnr2)
                self.keybindings(client, bufnr2)
                -- no highlight
                client.server_capabilities.semanticTokensProvider = nil
            end,
            single_file_support = true,
        })
    else
        vim.lsp.buf_attach_client(bufnr, clangd_client)
    end
end

return spec_clangd
