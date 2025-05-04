function close_curr_buffer()
    local curr_buf = vim.api.nvim_get_current_buf()
    vim.cmd("BufferLineCyclePrev")
    vim.cmd("bdelete "..curr_buf)
end

return util
