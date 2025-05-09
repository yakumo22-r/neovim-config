require("base_func")
local stru = require('strutils')

---@class BUFU
local bufu = {}

function bufu.close_curr_buffer(buf)
    local curr_buf = vim.api.nvim_get_current_buf()
    vim.cmd("BufferLineCyclePrev")
    vim.cmd("bdelete " .. curr_buf)
end

function bufu.TrimStart(line)

    local space_num = 0
    local match = string.match(line, "^%s*") or ""
    space_num = #match

    return string.sub(line, space_num + 1),space_num
end

function bufu.RmLinePrefix(line,prefix_r,clear_space)

    local space_num = 0
    if clear_space then
        space_num = #(string.match(line, "^%s*"))
    end

    local match = string.match(line, "^"..prefix_r) or ""

    return string.sub(line, space_num + #match + 1),space_num
end

function bufu.SurroundSymbols(_beg,_end,add)
    _end = _end or _beg

    local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

    local lines = vim.fn.getline(start_row, end_row)
    local len = #lines

    local first_char = lines[1]:sub(start_col, start_col)
    local last_char = lines[len]:sub(end_col, end_col)

    if add == nil then
        add = (first_char == _beg and last_char == _end) and 0 or 1
    elseif type(add) == "string" then
        add = tonumber(add)
    end

    local colmul = len==1 and 1 or 0

    local fixend = end_col

    if add == 1 then
        lines[1] = lines[1]:sub(1, start_col - 1) .. _beg .. lines[1]:sub(start_col)
        end_col = end_col + colmul
        lines[len] = lines[len]:sub(1, end_col) .. _end .. lines[len]:sub(end_col + 1)
        fixend = end_col
    else
        lines[1] = lines[1]:sub(1, start_col - 1) .. lines[1]:sub(start_col + 1)
        end_col = end_col - colmul
        lines[len] = lines[len]:sub(1, end_col-1) .. lines[len]:sub(end_col+1)
        fixend = end_col - 2
    end

    vim.fn.setline(start_row, lines)
    vim.cmd("normal! v")
    vim.api.nvim_buf_set_mark(0, "<", start_row, start_col, {})
    vim.api.nvim_win_set_cursor(0, {end_row, fixend})
end

---@type integer?
bufu.main_win = nil

function bufu:get_main_win()
    if not self.main_win then
        for _,win in ipairs(vim.api.nvim_list_wins())do
            if vim.api.nvim_win_get_config(win).relative == "" then
                self.main_win = win
                break
            end
        end

    end

    return self.main_win
end

function bufu.open_file(path)
    local buf = vim.fn.bufnr(path)

    if buf < 0 or not vim.api.nvim_buf_is_valid(buf) then
        buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(buf, path)
        vim.bo[buf].buftype = ""
        vim.bo[buf].bufhidden = "hide"
        -- vim.bo[buf].swapfile = false
        vim.api.nvim_buf_call(buf, function ()
            vim.cmd("edit " .. vim.fn.fnameescape(path))
        end)
    end

    vim.api.nvim_win_set_buf(bufu:get_main_win(), buf)
end

function bufu.SurroundSymbolsCMD(l,r,add)
    local cmd = ":lua YKM22.bufu.SurroundSymbols('" .. l
    if r then
        cmd = cmd.. "','" .. r 
    end
    if add ~= nil then
        cmd = cmd .. "','" .. (add and 1 or 0)
    end
    return   cmd .. "')<CR>"
end


YKM22.bufu = bufu

return bufu
