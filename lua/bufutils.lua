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

    -- 处理首行和尾行的部分

    local first_char = lines[1]:sub(start_col, start_col)
    local last_char = lines[#lines]:sub(end_col, end_col)

    -- 如果首尾字符已经是符号，则移除它们
    if first_char == _beg and last_char == _end then
        lines[1] = lines[1]:sub(1, start_col - 1) .. lines[1]:sub(start_col + 1)
        lines[#lines] = lines[#lines]:sub(1, end_col-2) .. lines[#lines]:sub(end_col+1)
    else
        lines[1] = lines[1]:sub(1, start_col - 1) .. _beg .. lines[1]:sub(start_col)
        lines[#lines] = lines[#lines]:sub(1, end_col+1) .. _end .. lines[#lines]:sub(end_col + 2)
    end

    -- 更新选中的文本
    vim.fn.setline(start_row, lines)
end


function bufu.ToggleNormal(prefix_c, prefix_r, sp)
    prefix_r = prefix_r or prefix_c

    sp = sp or ''

    local current_line = vim.api.nvim_get_current_line()
    local prefix = string.match(current_line, "^%s*")

    if string.find(current_line, "^%s*" .. prefix_r) then
        local main_text = string.sub(current_line, #prefix + #prefix_c + 1)
        vim.api.nvim_set_current_line(prefix .. stru.trim_one(main_text))
    else
        if #current_line == #prefix + #prefix_c then
            string.sub(current_line, #prefix + #prefix_c + 1)
        else
            vim.api.nvim_set_current_line(prefix .. prefix_c .. sp .. string.sub(current_line, #prefix + 1))
        end
    end
end

YKM.bufu = bufu

return bufu
