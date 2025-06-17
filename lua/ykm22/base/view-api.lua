---@class ykm22.nvim.ViewApi
local M = {}

M.StyleNormal = "Normal"
M.StyleError = "DiagnosticError"
M.StyleWarn = "DiagnosticWarn"
M.StyleInfo = "DiagnosticInfo"
M.StyleOk = "DiagnosticOk"
M.StyleHint = "DiagnosticHint"

-- deprecated wrap
M.add_highlight = vim.api.nvim_buf_add_highlight



-- nvim_buf_set_extmark
---@param buf integer
---@param ns_id integer
---@param hl_group string
---@param range integer[] 1: start_line, 2: start_col, 3: end_line?, 4: end_col?
--- @return integer # Id of the created/updated extmark
function M.set_extmark(buf,ns_id,hl_group,range)
    local start_line = range[1] - 1
    local start_col = range[2] - 1
    local end_line = range[3] and range[3] - 1
    local end_col = range[4] or -1

    if not end_line then
        end_line = start_line + 1
        end_col = 0
    elseif end_col < 0 then
        end_col = 0
    end

    return vim.api.nvim_buf_set_extmark(buf, ns_id, start_line, start_col, {
        end_row = end_line,
        end_col = end_col,
        hl_group = hl_group,
        strict = false,
    })
end

---@class ykm22.nvim.StyleCell
---@field text? string
---@field style? string
---@field indent? integer char-width
---@field width? integer char-width
---@field byte_width? integer char-width

---@class ykm22.nvim.BufStyle
---@field style string
---@field _start integer
---@field _end integer

---@param text string
---@param indent? integer char-index
---@param style? string
---@return ykm22.nvim.StyleCell
function M.style_cell(text, indent, style)
    return {
        text = text,
        style = style,
        indent = indent or 0,
        width = vim.fn.strdisplaywidth(text),
        byte_width = #text,
    }
end

---@param cells ykm22.nvim.StyleCell[]
---@return string line, ykm22.nvim.BufStyle[] styles
function M.get_style_line(cells)
    local texts = {}

    ---@type ykm22.nvim.BufStyle[]
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
---@param ns_id integer
---@param line_id integer
---@param buf_styles ykm22.nvim.BufStyle[]
function M.set_styles(buf,ns_id, line_id, buf_styles)
    for _,v in ipairs(buf_styles) do
        M.set_extmark(buf, ns_id, v.style or M.StyleNormal, {
            line_id, v._start,
            line_id, v._end,
        })
        -- M.add_highlight(buf,
        -- -1, v.style or M.StyleNormal, line_id-1, v._start-1, v._end-1)
    end
end

---@param text string
---@param width integer
---@param fill string?
---@return string ,integer height
function M.center_text(text, width, fill)
    fill = fill or " "
    local fillLen = vim.fn.strdisplaywidth(fill) 
    local txt_w = vim.fn.strdisplaywidth(text)
    local padding = string.rep(fill, math.floor((width - txt_w) / 2 / fillLen))

    if txt_w >= width then
        return text, math.ceil(txt_w / width) - 1
    end
    return padding .. text .. padding, 0
end

---@param text string
---@param width integer
---@param fill string?
---@return string ,integer height
function M.right_text(text, width, fill)
    fill = fill or " "
    local fillLen = vim.fn.strdisplaywidth(fill) 
    local txt_w = vim.fn.strdisplaywidth(text)
    local padding = string.rep(fill, math.floor((width - txt_w) / fillLen))

    if txt_w >= width then
        return text, math.ceil(txt_w / width) - 1
    end
    return padding .. text, 0

end

---@param text string
---@param width integer
---@param style? string
---@return string, BufStyle
function M.short_text(text, width, style)
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

return M
