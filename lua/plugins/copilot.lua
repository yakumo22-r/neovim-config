local EVENT = false

local function is_dos_text_file_buf()
    return vim.bo.fileformat ~= "unix" 
        and vim.bo.buftype ~= "nofile" 
        and vim.bo.filetype ~= ''
end

local function copilot_event()
    if not EVENT then
        EVENT = true
        -- set fileformat to unix
        if vim.fn.has("win32") == 1 then
            if is_dos_text_file_buf() then
                vim.bo.fileformat = "unix"
            end

            vim.api.nvim_create_autocmd({"FileType"}, {
                pattern = "*",
                callback = function(args)
                    if is_dos_text_file_buf() then
                        vim.bo.fileformat = "unix"
                    end
                end,
            })
        end
    end
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
                copilot_event()
            else
                print("Copilot OFF")
            end
        end)

        --   if vim.bo.fileformat == "dos" then
        --     completion = string.gsub(completion, "\r", "")
        --   end
        --   return completion
        -- end

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
