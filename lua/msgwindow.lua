local MsgWindow = {}

MsgWindow.StyleNormal = "Normal"
MsgWindow.StyleError = "DiagnosticError"
MsgWindow.StyleWarn = "DiagnosticWarn"
MsgWindow.StyleInfo = "DiagnosticInfo"

local function layout_middle(width, height,borderStyle)
    borderStyle = borderStyle or MsgWindow.StyleInfo
    local ui = vim.api.nvim_list_uis()[1]
    local row = math.floor((ui.height - height) / 2)
    local col = math.floor((ui.width - width) / 2)
    return {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = { { "╭", borderStyle }, { "─", borderStyle }, { "╮", borderStyle },
             { "│", borderStyle }, { "╯", borderStyle }, { "─", borderStyle },
             { "╰", borderStyle }, { "│", borderStyle } },
    }
end


---@param text string
---@param width number
---@param fill? string
---@return string,number
local function center_text(text, width, fill)
    fill = fill or " "
    local txt_w = vim.fn.strdisplaywidth(text)
    local padding = string.rep(fill,math.floor((width - txt_w)/2))

    if txt_w >= width then
        return text, math.ceil(txt_w / width)-1
    end
    return padding..text..padding, 0
end

---@param title string
---@param msgs? string[]
---@param titleStyle? string
---@param msgStyles? string[]
function MsgWindow.Tip(title, msgs, titleStyle,msgStyles)
    local width = 80
    msgs = msgs or {"(empty)"}

    title = "<|"..title.."|>"
    local l,n = center_text(title,width)
    local lines = {l}
    local height = 0
    table.insert(lines, "")
    for _,msg in ipairs(msgs) do
        l,n = center_text(msg,width)
        height = height + n
        table.insert(lines, l)
    end
    table.insert(lines, "")
    l,n = center_text("Quit:q | enter",width)
    table.insert(lines, l)
    height = math.min(height + #lines + n, 120)

    titleStyle = titleStyle or MsgWindow.StyleInfo
    msgStyles = msgStyles or {}

    local buf = vim.api.nvim_create_buf(false, true)
    local opts = layout_middle(width, height, titleStyle)
    local win = vim.api.nvim_open_win(buf, true, opts)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    vim.api.nvim_buf_add_highlight(buf, -1, titleStyle, 0, 0, #lines[1])
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", #lines - 1, 0, #lines[#lines])

    for i=3,#lines-2 do
        local style = msgStyles[i-1] or MsgWindow.StyleNormal
        vim.api.nvim_buf_add_highlight(buf, -1, style, i-1, 0, #lines[i])
    end

    vim.api.nvim_set_option_value("modifiable", false ,{buf=buf})
    vim.api.nvim_set_option_value("modifiable", false,{buf=buf})
    vim.api.nvim_set_option_value("buftype", "nofile",{buf=buf})
    vim.api.nvim_set_option_value("bufhidden", "wipe",{buf=buf})

    vim.api.nvim_buf_set_keymap(buf,"n", "<CR>", ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf,"n", "q", ":lua vim.api.nvim_win_close(" .. win .. ", true)<CR>", { noremap = true, silent = true })
end

return MsgWindow
