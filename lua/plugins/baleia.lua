local function set_buffer(buf)
    if not buf or buf==0 then
        buf = vim.api.nvim_get_current_buf()
    end

    vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
    vim.api.nvim_set_option_value("readonly", false, { buf = buf })
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.g.baleia.buf_set_lines(buf,0,-1,true,lines)

    vim.api.nvim_set_option_value("readonly", true, { buf = buf })
    vim.api.nvim_set_option_value("modified", false, { buf = buf })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

return {
    "m00qek/baleia.nvim",
    version = "*",
    config = function()
        vim.g.baleia = require("baleia").setup({ })

        if vim.fn.getenv("FLAG")=="GIT" then
            vim.defer_fn(set_buffer,0)
        end

        if vim.fn.getenv("FLAG")=="LOG" then
            vim.api.nvim_create_autocmd({ "BufReadPost" }, {
                callback = set_buffer,
            })
        end


        -- Command to colorize the current buffer
        vim.api.nvim_create_user_command("BaleiaColorize", function()
          vim.g.baleia.once(vim.api.nvim_get_current_buf())
        end, { bang = true })

        -- Command to show logs 
        vim.api.nvim_create_user_command("BaleiaLogs", vim.g.baleia.logger.show, { bang = true })
  end,
}
