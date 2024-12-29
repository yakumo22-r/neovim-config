require("base_func")
local wu = require "window.window_util"

---@class WindowRect
---@field x integer
---@field y integer
---@field w integer
---@field h integer

---@class StaticWindow
local ins ={
    ---@type WindowRect
    rect = nil,
    ---@type integer?
    wnd = nil,
    ---@type integer
    buf = 0,
}

function ins:show()
    if self.wnd then return end
    
    local area = self.rect
    self.wnd = vim.api.nvim_open_win(self.buf, true, {
        relative = "editor",
        width = area.w,
        height = area.h,
        col = area.x,
        row = area.y,
        style = "minimal",
    })
end

---@param _start integer
---@param _end integer
---@param lines string[]
function ins:set_lines(_start,_end,lines)
    _end = _end and _end -1 or self.rect.h 
    _start = _start and _start -1 or 0
    vim.api.nvim_buf_set_lines(self.buf, _start, _end, false, lines)
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

---@param x integer
---@param y integer 
---@param w integer
---@param h integer
local function New_StaticWindow(x,y,w,h)
    ---@class StaticWindow
    local sw = table.clone(ins)

    sw.rect = {x=x,y=y,w=w,h=h}
    sw.buf = vim.api.nvim_create_buf(false, true)

    return sw
end

return New_StaticWindow
