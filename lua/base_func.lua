function close_curr_buffer()
    local curr_buf = vim.api.nvim_get_current_buf()
    vim.cmd("BufferLineCyclePrev")
    vim.cmd("bdelete "..curr_buf)
end

function table.clone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = table.clone(v) -- 递归拷贝子表
        else
            copy[k] = v
        end
    end
    return copy
end

YKM = {}
