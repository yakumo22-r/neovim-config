local util = {}

local bit = require("bit")

---@type function
util.bit_and = bit.band

---@type function
util.bit_or = bit.bor

---@type function
util.bit_xor = bit.bxor

---@type function
util.bit_not = bit.bnot

---@type function
util.bit_ls = bit.lshift

---@type function
util.bit_rs = bit.rshift


function close_curr_buffer()
    local curr_buf = vim.api.nvim_get_current_buf()
    vim.cmd("BufferLineCyclePrev")
    vim.cmd("bdelete " .. curr_buf)
end

function util.table_clone(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = util.table_clone(v) -- 递归拷贝子表
        else
            copy[k] = v
        end
    end
    return copy
end

function util.table_connect(s, n)
    local tbl = {}

    for k, v in pairs(s) do
        tbl[k] = v
    end

    for k, v in pairs(n) do
        tbl[k] = v
    end

    return tbl
end

YKM = {}

return util
