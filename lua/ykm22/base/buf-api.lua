---@class ykm22.nvim.BufApi
local M = {}

local opts = { noremap = true, silent = true }

---@param buf integer
---@param key string
---@param f string|function
---@param mode? string
function M.bind_key(buf, key, f, mode)
    mode = mode or "n"
    vim.keymap.set(mode, key, f, { buffer = buf, noremap = true, silent = true })
end

---@param buf integer
---@param k string
function M.nop_key(buf,k)
    vim.api.nvim_buf_set_keymap(buf, "n", k, "<Nop>", opts)
end

---@param buf integer
---@param open boolean
function M.set_modifiable(buf, open)
    vim.api.nvim_set_option_value("modifiable", open, { buf = buf })
end

---@param buf integer
function M.set_buf_nofile(buf)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
end

---@param buf integer
---@param index integer
---@param line string
function M.set_line(buf, index, line)
    local i = index - 1
    vim.api.nvim_buf_set_lines(buf, i, i, false, { line })
end

---@param buf integer
---@param _start? integer start_index:1
---@param _end? integer
---@param lines string[]
function M.set_lines(buf,_start,_end,lines)
    _end = _end or _start+#lines 
    _start = _start and _start -1 or 0

    vim.api.nvim_buf_set_lines(buf, _start, _end, false, lines)
end

---@param buf integer
function M.set_only_read(buf)
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

---@param buf integer
function M.set_buf_auto_close(buf)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
end

function M.block_fast_keys(buf, key, f, mode)
    for k, v in pairs(M.FK) do
        vim.api.nvim_buf_set_keymap(buf, "n", k, "<Nop>", opts)
    end
end


-- stylua: ignore start
M.MK = {
    w = "w", W = "W", e = "e", E = "E",
    b = "b", B = "B", v = "v", V = "V",
    l = "l", h = "h"
}
M.FK = {
    x = "x", X = "X", c = "c", C = "C", r = "r", R = "R", t = "t", T = "T",
    a = "a", A = "A", p = "p", P = "P", s = "s", S = "S", b = "b", B = "B",
    d = "d", D = "D", n = "n", N = "N", f = "f", F = "F", m = "m", M = "M",
    z = "z", Z = "Z", i = "i", I = "I", u = "u", U = "U", o = "o", O = "O",
}
-- stylua: ignore end

---@param buf integer?
---@param event string|string[]
---@param callback fun(ev: vim.api.keyset.create_autocmd.callback_args)
function M.autocmd(buf,event, callback)
    vim.api.nvim_create_autocmd(event, {
        buffer = buf,
        callback = callback,
    })
end

return M
