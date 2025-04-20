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

        vim.keymap.set('i', '<C-i>', 'copilot#Accept("\\<CR>")', {
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
