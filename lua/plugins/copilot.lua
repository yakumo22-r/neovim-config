local EVENT = false

local function is_dos_text_file_buf()
    local fmt = vim.bo.fileformat ~= "unix"
    local isfile = vim.bo.buftype ~= "nofile"
    if fmt and isfile then
        if vim.bo.filetype ~= '' then
            return true
        end
    end

    return false
end

return {
    "github/copilot.vim",
    event = "BufEnter",
    config = function()
        -- disable copilot by default
        vim.g.copilot_enabled = false

        -- open/close copilot by <C-Insert>
        
        vim.keymap.set('n', '<leader>co', function()
            vim.g.copilot_enabled = not vim.g.copilot_enabled
            if vim.g.copilot_enabled then
                print("Copilot ON")
                if not EVENT then
                    -- set fileformat to unix
                    if vim.fn.has("win32") == 1 then
                        if is_dos_text_file_buf() then
                            vim.opt.fileformat = "unix"
                            vim.opt.fileformats = { "unix" }
                        end

                        vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
                            pattern = "*",
                            callback = function()
                                if is_dos_text_file_buf() then
                                    vim.opt.fileformat = "unix"
                                end
                            end,
                        })
                    end
                end
            else
                print("Copilot OFF")
            end
        end)

        vim.keymap.set('n', '<leader>un', function()
            vim.cmd [[
                setlocal fileformat=unix
            ]]
        end)

        -- copilot keymaps
        vim.g.copilot_no_tab_map = true

        vim.keymap.set('i', '<C-a>', 'copilot#Accept("\\<CR>")', {
          expr = true,
          replace_keycodes = false
        })

        vim.keymap.set('i', '<C-d>', 'copilot#Next()', {
          expr = true,
          replace_keycodes = false
        })

        vim.keymap.set('i', '<C-u>', 'copilot#Previous()', {
          expr = true,
          replace_keycodes = false
        })


    end,
}
