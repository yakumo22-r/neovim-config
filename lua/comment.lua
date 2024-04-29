local prefix = {
    ["lua"] = "--",

    ["vim"] = '"',

    ["python"] = "#",
    ["sh"] = "#",
    ["bash"] = "#",
    ["zsh"] = "#",
}

local prefix_r = {
    ["lua"] = "%-%-",

    ["vim"] = '%"',

    ["python"] = "#",
    ["sh"] = "#",
    ["bash"] = "#",
    ["zsh"] = "#",
}

local function get_comment(t)
    local filetype = vim.bo.filetype

    if t[filetype] then
        return t[filetype]
    end

    return "//"
end

function ToggleCommentNormal()
    local comment = get_comment(prefix)
    local comment_r = get_comment(prefix_r)

    local current_line = vim.api.nvim_get_current_line()
    local leading_whitespace = string.match(current_line, "^%s*")

    if string.find(current_line, "^%s*" .. comment_r) then
        local uncomment = string.gsub(current_line, "^%s*" .. comment_r, leading_whitespace)
        vim.api.nvim_set_current_line(uncomment)
    else
        if #current_line == #leading_whitespace + #comment then
            string.sub(line, #leading_whitespace + #comment + 1)
        else
            vim.api.nvim_set_current_line(leading_whitespace .. comment .. string.sub(current_line, #leading_whitespace + 1))
        end
    end
end

function ToggleCommentVisual()
    local comment = get_comment(prefix)
    local comment_r = get_comment(prefix_r)

    local selection_start = vim.api.nvim_buf_get_mark(0, "<")
    local selection_end = vim.api.nvim_buf_get_mark(0, ">")

    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local modes = {}
    for i, line in ipairs(lines) do
        modes[i] = {}

        if not string.match("^[\t\n ]+$", line) then
            modes[i].ignore = false
            modes[i].comment = not string.find(line, "^%s*" .. comment_r)
        else
            modes[i].ignore = true
        end
    end
    local mode_comment = modes[1].comment

    local min_p = math.huge
    local prefix_whitespace = ""

    for i, line in ipairs(lines) do
        if not modes[i].ignore then
            local leading_whitespace = string.match(line, "^%s*")
            if #leading_whitespace < min_p and #leading_whitespace >= 0 then
                prefix_whitespace = leading_whitespace
                min_p = #leading_whitespace
            end
        end
    end

    if mode_comment then
        for i, line in ipairs(lines) do
            if not modes[i].ignore then
                local subline = string.sub(line, #prefix_whitespace + 1)
                lines[i] = prefix_whitespace .. comment .. subline
            end
        end
    else
        for i, line in ipairs(lines) do
            if not modes[i].ignore and not modes[i].comment then
                if #line == #prefix_whitespace + #comment then
                    lines[i] = string.sub(line, #prefix_whitespace + #comment + 1)
                else
                    lines[i] = string.gsub(line, "^%s*" .. comment_r, prefix_whitespace)
                end
            end
        end
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
vim.api.nvim_win_set_cursor(0, {line1, 0})
vim.fn.setpos("'>", {0, line2, 0, 0})
    --vim.api.nvim_buf_set_mark(0, "<", selection_start)
    --vim.api.nvim_buf_set_mark(0, ">", selection_end)
end

local opt = { noremap = true, silent = true }
vim.keymap.set("n", "<C-_>", ":lua ToggleCommentNormal()<CR>", opt)
vim.keymap.set("v", "<C-_>", ":lua ToggleCommentVisual()<CR>", opt)
