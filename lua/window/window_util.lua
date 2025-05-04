local opts = { noremap = true, silent = true }
local api = vim.api

local WU = {}

WU.StyleNormal = "Normal"
WU.StyleError = "DiagnosticError"
WU.StyleWarn = "DiagnosticWarn"
WU.StyleInfo = "DiagnosticInfo"
WU.StyleVar = "NavicIconsVariable"

---@class BufStyle
---@field style string
---@field _start integer
---@field _end integer

---@class StyleCell
---@field text? string
---@field style? string
---@field indent? integer char-width
---@field width? integer char-width
---@field byte_width? integer char-width

---@param text string
---@param indent? integer char-index
---@param style? string
---@return StyleCell
function WU._cell(text, indent, style)
    return {
        text = text,
        style = style,
        indent = indent or 0,
        width = vim.fn.strdisplaywidth(text),
        byte_width = #text,
    }
end

---@param cells StyleCell[]
---@return string line, BufStyle[] styles
function WU.get_style_line(cells)
    local texts = {}

    ---@type BufStyle[]
    local styles = {}

    local ii = 1
    for _, v in ipairs(cells) do
        table.insert(texts, v.text)
        local l = string.len(v.text)

        if v.style then
            table.insert(styles, { style = v.style, _start = ii, _end = ii + l - 1 })
        end

        ii = ii + l
    end

    return table.concat(texts), styles
end

---@param buf integer
---@param open boolean
function WU.set_modifiable(buf, open)
    api.nvim_set_option_value("modifiable", open, { buf = buf })
end

---@param buf integer
---@param index integer
---@param line string
function WU.set_line(buf, index, line)
    local i = index - 1
    vim.api.nvim_buf_set_lines(buf, i, i, false, { line })
end

---@param buf integer
function WU.set_only_read(buf)
    api.nvim_set_option_value("modifiable", false, { buf = buf })
end

---@param buf integer
function WU.set_buf_auto_close(buf)
    api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
end

---@param text string
---@param width integer
---@return string ,integer height
function WU.center_text(text, width)
    fill = fill or " "
    local txt_w = vim.fn.strdisplaywidth(text)
    local padding = string.rep(fill, math.floor((width - txt_w) / 2))

    if txt_w >= width then
        return text, math.ceil(txt_w / width) - 1
    end
    return padding .. text .. padding, 0
end

---@param text string
---@param width integer
---@param style? string
---@return string, BufStyle
function WU.short_text(text, width, style)
    local textw = vim.fn.strdisplaywidth(text)
    local exceed = textw - width 
    while exceed > 0 do
        text = text:sub(1, #text-exceed-3).."..."
        textw = vim.fn.strdisplaywidth(text)
        exceed = textw - width
    end
    return text, {
        style = style,
        _start = 1,
        _end = #text + 1,
    }
end

local edit_keys = { "i", "I", "a", "A", "o", "O", "c", "C", "d", "D", "p", "P", "u", "U", "r", "R", "x", "X", "s", "S" }
---@param buf integer
function WU.block_edit_keys(buf)
    for _, k in ipairs(edit_keys) do
        api.nvim_buf_set_keymap(buf, "v", k, "<Nop>", opts)
        api.nvim_buf_set_keymap(buf, "n", k, "<Nop>", opts)
    end
end

---@param buf integer
---@param key string
---@param f string|function
---@param mode? string
function WU.bind_key(buf, key, f, mode)
    mode = mode or "n"
    vim.keymap.set(mode, key, f, { buffer = buf, noremap = true, silent = true })
end

---@param width integer
---@param height integer
---@param borderStyle string
---@param x? integer offset
---@param y? integer offset
function WU.layout_middle(width, height, borderStyle, x, y)
    borderStyle = borderStyle or WU.StyleInfo
    local ui = vim.api.nvim_list_uis()[1]
    local row = math.floor((ui.height - height) / 2) + (x or 0)
    local col = math.floor((ui.width - width) / 2) + (y or 0)
    return {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = {
            { "╭", borderStyle },
            { "─", borderStyle },
            { "╮", borderStyle },
            { "│", borderStyle },
            { "╯", borderStyle },
            { "─", borderStyle },
            { "╰", borderStyle },
            { "│", borderStyle },
        },
    }
end

---@class FileIconStyle
---@field hl_group string
---@field icon string

---@type table<string,FileIconStyle>
-- local file_icons = {}

---@param filename string
---@return string icon,string hl_group
function WU.get_icon_style(filename)
    local filetype = vim.filetype.match({ filename = filename }) or "txt"
    -- if not file_icons[filetype] then
    local web_devicons = require("nvim-web-devicons")
    local icon, color = web_devicons.get_icon_by_filetype(filetype)
    return icon, color
    --     end

    --     local item = file_icons[filetype]

    --     return item.icon, item.hl_group
end

---@param window StaticWindow
---@return boolean
function WU.is_focus(window)
    local wnd = window.wnd
    if wnd then
        local current_win = api.nvim_get_current_win()
        return api.nvim_win_is_valid(wnd) and current_win == wnd
    end
    return false
end

return WU
