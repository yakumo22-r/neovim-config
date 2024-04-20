return {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            open_mapping = [[<c-t>]],
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
