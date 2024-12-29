local opts = { noremap = true, silent = true }
local api = vim.api


local WU = {}

WU.StyleNormal = "Normal"
WU.StyleError = "DiagnosticError"
WU.StyleWarn = "DiagnosticWarn"
WU.StyleInfo = "DiagnosticInfo"

---@param buf integer
---@param open boolean
function WU.set_modifiable(buf, open)
    api.nvim_set_option_value("modifiable", open,{buf=buf})
end

---@param buf integer
---@param index integer
---@param line string
function WU.set_line(buf, index, line)
    local i = index - 1
    vim.api.nvim_buf_set_lines(buf, i, i, false, {line})
end


---@param buf integer
function WU.set_only_read(buf)
    api.nvim_set_option_value("modifiable", false, {buf=buf})
end

---@param buf integer
function WU.set_buf_auto_close(buf)
    api.nvim_set_option_value("bufhidden", "wipe", {buf=buf})
end


---@param text string
---@param width integer
---@return string ,integer height
function WU.center_text(text, width)
    fill = fill or " "
    local txt_w = vim.fn.strdisplaywidth(text)
    local padding = string.rep(fill,math.floor((width - txt_w)/2))

    if txt_w >= width then
        return text, math.ceil(txt_w / width)-1
    end
    return padding..text..padding, 0
end

local edit_keys = { "i","I", "a", "A","o","O", "c", "C", "d", "D", "p", "P", "u", "U", "r", "R", "x", "X", "s", "S"}
---@param buf integer
function WU.block_edit_keys(buf)
    for _,k in ipairs(edit_keys) do
        api.nvim_buf_set_keymap(buf, 'v', k, '<Nop>', opts)
        api.nvim_buf_set_keymap(buf, 'n', k, '<Nop>', opts)
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
function WU.layout_middle(width, height, borderStyle,x,y)
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
        border = { { "╭", borderStyle }, { "─", borderStyle }, { "╮", borderStyle },
             { "│", borderStyle }, { "╯", borderStyle }, { "─", borderStyle },
             { "╰", borderStyle }, { "│", borderStyle } },
    }
end
    
return WU

