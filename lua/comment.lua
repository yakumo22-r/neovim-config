local cmprefix = {
    ["lua"] = "--",

    ["vim"] = '"',

    ["python"] = "#",
    ["sh"] = "#",
    ["bash"] = "#",
    ["zsh"] = "#",
}

local cmprefix_r = {
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

local function trim_one(str)
    if string.sub(str, 1, 1) == " " then
        return string.sub(str, 2)
    else
        return str
    end
end

function ToggleCommentNormal()
    local comment = get_comment(cmprefix)
    local comment_r = get_comment(cmprefix_r)

    local current_line = vim.api.nvim_get_current_line()
    local prefix = string.match(current_line, "^%s*")

    if string.find(current_line, "^%s*" .. comment_r) then
        local main_text = string.sub(current_line, #prefix + #comment + 1)
        vim.api.nvim_set_current_line(prefix .. trim_one(main_text))
    else
        if #current_line == #prefix + #comment then
            string.sub(current_line, #prefix + #comment + 1)
        else
            vim.api.nvim_set_current_line(prefix .. comment .. " " .. string.sub(current_line, #prefix + 1))
        end
    end
end

local function FindShortPrefix(lines, modes)
    local min_p = math.huge
    local min_prefix = ""

    for i, line in ipairs(lines) do
        if not modes or not modes[i].ignore then
            local prefix = string.match(line, "^%s*")
            if #prefix < min_p and #prefix >= 0 then
                min_prefix = prefix
                min_p = #min_prefix
            end
        end
    end

    return min_prefix
end

function ToggleCommentVisual()
    local cm = get_comment(cmprefix)
    local cmr = get_comment(cmprefix_r)

    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local modes = {}
    for i, line in ipairs(lines) do
        modes[i] = {}

        if not string.match(line, "^%s*$") then
            modes[i].ignore = false
            modes[i].comment = not string.find(line, "^%s*" .. cmr)
        else
            modes[i].ignore = true
        end
    end
    local mode_comment = modes[1].comment

    local prefix = FindShortPrefix(lines, modes)

    if mode_comment then
        for i, line in ipairs(lines) do
            if not modes[i].ignore then
                local subline = string.sub(line, #prefix + 1)
                lines[i] = prefix .. cm .. " " .. subline
            end
        end
    else
        for i, line in ipairs(lines) do
            if not modes[i].ignore and not modes[i].comment then
                local m_prefix = string.match(line, "^%s*")
                local pmlen = #m_prefix + #cm
                local main_text = string.sub(line, pmlen + 1)
                if #line == pmlen then
                    lines[i] = main_text
                else
                    lines[i] = prefix .. trim_one(main_text)
                end
            end
        end
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.api.nvim_win_set_cursor(0, { line1, 0 })
    vim.fn.setpos("'>", { 0, line2, 0, 0 })
end

local function CommentLine(cm, line, prefix)
    prefix = prefix or string.match(line, "^%s*")
    return prefix .. cm .. " " .. string.sub(line, #prefix + 1)
end

local function UnCommentLine(cm, cmr, line)
    if string.find(line, "^%s*" .. cmr) then
        local prefix = string.match(line, "^%s*")
        local main_text = string.sub(line, #prefix + #cm + 1)
        return prefix .. trim_one(main_text)
    else
        return line
    end
end

function AddCommentNormal()
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(CommentLine(get_comment(cmprefix), line))
end

function RmCommentNormal()
    local cm = get_comment(cmprefix)
    local cmr = get_comment(cmprefix_r)
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(UnCommentLine(cm, cmr, line))
end

function AddCommentVisual()
    local cm = get_comment(cmprefix)

    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local prefix = FindShortPrefix(lines)
    for i, line in ipairs(lines) do
        lines[i] = CommentLine(cm, line,prefix)
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.api.nvim_win_set_cursor(0, { line1, 0 })
    vim.fn.setpos("'>", { 0, line2, 0, 0 })
end

function RmCommentVisual()
    local cm = get_comment(cmprefix)
    local cmr = get_comment(cmprefix_r)

    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    for i, line in ipairs(lines) do
        lines[i] = UnCommentLine(cm, cmr, line)
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.api.nvim_win_set_cursor(0, { line1, 0 })
    vim.fn.setpos("'>", { 0, line2, 0, 0 })
end

local opt = { noremap = true, silent = true }
vim.keymap.set("n", "<C-_>", ":lua ToggleCommentNormal()<CR>", opt)
vim.keymap.set("v", "<C-_>", ":lua ToggleCommentVisual()<CR>", opt)
vim.keymap.set("n", "<C-/>", ":lua ToggleCommentNormal()<CR>", opt)
vim.keymap.set("v", "<C-/>", ":lua ToggleCommentVisual()<CR>", opt)

vim.keymap.set("n", "<leader>=", ":lua AddCommentNormal()<CR>", opt)
vim.keymap.set("v", "<leader>=", ":lua AddCommentVisual()<CR>", opt)
vim.keymap.set("n", "<leader>-", ":lua RmCommentNormal()<CR>", opt)
vim.keymap.set("v", "<leader>-", ":lua RmCommentVisual()<CR>", opt)
