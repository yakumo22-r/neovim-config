function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<C-n>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<c-t>]],
            direction = 'float',
            shade_terminals=true,
        })
        function TermExec(cmd, name, id)
            local terms = require("toggleterm.terminal")
            local term = terms.get_or_create_term(id, nil, nil, name)
            local go_back
            if not term:is_open() then
                term:open(nil, nil)
            end

            if term:is_float() then
                go_back = false
            end

            if go_back == nil then
                go_back = true
            end
            term:send(cmd, false)
        end
    end,
}
