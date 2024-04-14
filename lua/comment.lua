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
        local uncomment =
            string.gsub(current_line, "^%s*" .. comment_r, leading_whitespace)
        vim.api.nvim_set_current_line(uncomment)
    else
        if #current_line == #leading_whitespace + #comment then
            string.sub(line, #leading_whitespace + #comment + 1)
        else
            vim.api.nvim_set_current_line(
                leading_whitespace
                    .. comment
                    .. string.sub(current_line, #leading_whitespace + 1)
            )
        end
    end
end

function ToggleCommentVisual()
    local comment = get_comment(prefix)
    local comment_r = get_comment(prefix_r)

    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local mode_comment = true
    local min_p = math.huge
    local prefix_whitespace = ""

    for i, line in ipairs(lines) do
        if mode_comment and string.find(line, "^%s*" .. comment_r) then
            mode_comment = false
        end
        local leading_whitespace = string.match(line, "^%s*")
        if #leading_whitespace < min_p and #leading_whitespace >= 0 then
            prefix_whitespace = leading_whitespace
            min_p = #leading_whitespace
        end
    end

    if mode_comment then
        for i, line in ipairs(lines) do
            local subline = string.sub(line, #prefix_whitespace + 1)
            lines[i] = prefix_whitespace .. comment .. subline
        end
    else
        for i, line in ipairs(lines) do
            if #line == #prefix_whitespace + #comment then
                lines[i] = string.sub(line, #prefix_whitespace + #comment + 1)
            else
                lines[i] =
                    string.gsub(line, "^%s*" .. comment_r, prefix_whitespace)
            end
        end
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
end

local opt = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>=", ":lua ToggleCommentNormal()<CR>", opt)
vim.keymap.set("v", "<leader>=", ":lua ToggleCommentVisual()<CR>", opt)
