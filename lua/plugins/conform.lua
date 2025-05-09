---@param bufnr integer
---@return integer start_offset
---@return integer end_offset
local function get_offsets_from_range (bufnr, range)
  local row = range.start[1] - 1
  local end_row = range["end"][1] - 1
  local col = range.start[2]
  local end_col = range["end"][2]
  local start_offset = vim.api.nvim_buf_get_offset(bufnr, row) + col
  local end_offset = vim.api.nvim_buf_get_offset(bufnr, end_row) + end_col
  return start_offset, end_offset
end
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

        -- Set up formatters
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

        conform.formatters.stylua = {
            inherit = true,
            command = "stylua",
            range_args = function(self, ctx)
                local start_offset, end_offset = get_offsets_from_range(ctx.buf, ctx.range)
                return {
                    "--search-parent-directories",
                    "--stdin-filepath",
                    ctx.filename,
                    "--range-start",
                    tostring(start_offset),
                    "--range-end",
                    tostring(end_offset+1),
                    "-",
                }
            end,
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
                }, function()
                    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
                end)
            end)
        end)
    end,
}
