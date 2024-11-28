require("base_func")
local stru = require('strutils')

local bufu = {}

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

function bufu.SurroundSymbols(_beg,_end)
    _end = _end or _beg

    local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
    local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))

    local lines = vim.fn.getline(start_row, end_row)

    local first_char = lines[1]:sub(start_col, start_col)
    local last_char = lines[#lines]:sub(end_col, end_col)

    if first_char == _beg and last_char == _end then
        lines[1] = lines[1]:sub(1, start_col - 1) .. lines[1]:sub(start_col + 1)
        lines[#lines] = lines[#lines]:sub(1, end_col-2) .. lines[#lines]:sub(end_col+1)
    else
        lines[1] = lines[1]:sub(1, start_col - 1) .. _beg .. lines[1]:sub(start_col)
        lines[#lines] = lines[#lines]:sub(1, end_col+1) .. _end .. lines[#lines]:sub(end_col + 2)
    end

    vim.fn.setline(start_row, lines)
end

YKM.bufu = bufu

return bufu
