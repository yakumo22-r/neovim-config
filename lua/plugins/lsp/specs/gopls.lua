local lsp_base = require("plugins.lsp.tools.lsp_base")

local filetypes = { "go", "gomod", "gowork", "gotmpl" }

local spec_clangd = lsp_base.new_entity(filetypes)

---@type integer?
local clangd_client = nil

---@param bufnr integer
function spec_clangd:attach_buf(bufnr)
    if not clangd_client then
        clangd_client = vim.lsp.start({
            name = "gopls",
            cmd = { lsp_base.cmd("gopls") },
            filetypes = filetypes,
            root_markers = { "go.work", "go.mod", ".git" },
            capabilities = self.capabilities,
            on_init = function(client)
                vim.lsp.buf_attach_client(bufnr, clangd_client)
            end,
            on_attach = function(client, bufnr2)
                self.keybindings(client, bufnr2)
            end,
            single_file_support = true,
        })
    else
        vim.lsp.buf_attach_client(bufnr, clangd_client)
    end
end

return spec_clangd
