local util = require("base_func")
local wu = require "window.window_util"

---@class WindowRect
---@field x integer
---@field y integer
---@field w integer
---@field h integer

---@class StaticWindow
local ins ={
    ---@type integer?
    wnd = nil,

    ---@type integer
    buf = 0,

    ---@type WindowRect
    rect = nil,

    style = "minimal",
}

---@type boolean
ins.focusable = false

---@param x integer
---@param y integer 
---@param w integer
---@param h integer
local function New_StaticWindow(x,y,w,h)
    ---@class StaticWindow
    local sw = util.table_clone(ins)

    sw.rect = {x=x,y=y,w=w,h=h}
    sw.buf = vim.api.nvim_create_buf(false, true)

    return sw
end


function ins:show()
    if self.wnd then return end

    local area = self.rect
    self.wnd = vim.api.nvim_open_win(self.buf, true, {
        relative = "editor",
        width = area.w,
        height = area.h,
        col = area.x,
        row = area.y,
        focusable = self.focusable,
        style = self.style,
    })
end

function ins:resize(w,h)
    self.rect.w = w
    self.rect.h = h
    if self.wnd then
        vim.api.nvim_win_set_config(self.wnd, {
            width = w,
            height = h,
        })
    end
end

---@param _start integer
---@param _end integer
---@param lines string[]
function ins:set_lines(_start,_end,lines)
    _end = _end or _start+#lines 
    _start = _start and _start -1 or 0

    vim.api.nvim_buf_set_lines(self.buf, _start, _end, false, lines)
end

---@param line_id integer
---@param buf_styles BufStyle[]
function ins:set_styles(line_id, buf_styles)
    for _,v in ipairs(buf_styles) do
        vim.api.nvim_buf_add_highlight(self.buf,
        -1, v.style or wu.StyleNormal, line_id-1, v._start-1, v._end-1)
    end
end

function ins:set_select_window()
    self.style = nil

end

---@param open boolean
function ins:set_modifiable(open)
    vim.api.nvim_set_option_value("modifiable", open,{buf=self.buf})
end

function ins:focus()
    if self.wnd and self.wnd > 0 then
        vim.api.nvim_set_current_win(self.wnd)
    end
end

function ins:hide()
    if not self.wnd then return end
    
    vim.api.nvim_win_close(self.wnd, true)
    self.wnd = nil
end

function ins:destroy()
    self:hide()
    vim.api.nvim_buf_delete(self.buf, { force = true })
end

return New_StaticWindow
