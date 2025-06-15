---@class ykm22.nvim.BufApi
local M = {}

local opts = { noremap = true, silent = true }

local edit_keys = { "i", "I", "a", "A", "o", "O", "c", "C", "d", "D", "p", "P", "u", "U", "r", "R", "x", "X", "s", "S" }
---@param buf integer
function M.block_edit_keys(buf)
    for _, k in ipairs(edit_keys) do
        vim.api.nvim_buf_set_keymap(buf, "v", k, "<Nop>", opts)
        vim.api.nvim_buf_set_keymap(buf, "n", k, "<Nop>", opts)
    end
end

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
    for _, k in ipairs(M.FK) do
        vim.api.nvim_buf_set_keymap(buf, "n", k, "<Nop>", opts)
    end
end

-- stylua: ignore start
M.FK = {
    w = "w", W = "W", x = "x", X = "X",
    e = "e", E = "E", c = "c", C = "C",
    r = "r", R = "R", v = "v", V = "V",
    t = "t", T = "T", l = "l", L = "L",
    a = "a", A = "A", p = "p", P = "P",
    s = "s", S = "S", b = "b", B = "B",
    d = "d", D = "D", n = "n", N = "N",
    f = "f", F = "F", m = "m", M = "M",
    z = "z", Z = "Z", i = "i", I = "I",
}
-- stylua: ignore end

return M
