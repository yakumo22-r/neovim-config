local util = require("base_func")
local Window = require "window.window"
local wu = require "window.window_util"

local WG = {}

WG.Top = 8
WG.Bottom = 4
WG.Left = 2
WG.Right = 1

WG.Border = {
    [0]='•',
    [util.bit_or(WG.Left,WG.Right)] = '─', 
    [util.bit_or(WG.Left,WG.Right,WG.Bottom)] = '┬', 
    [util.bit_or(WG.Left,WG.Right,WG.Top)] = '┴', 
    [util.bit_or(WG.Top,WG.Bottom)] = '│', 
    [util.bit_or(WG.Top,WG.Bottom,WG.Left,WG.Right)] = '┼', 
    [util.bit_or(WG.Top,WG.Bottom,WG.Left)] = '┤', 
    [util.bit_or(WG.Top,WG.Bottom,WG.Right)] = '├', 
    [util.bit_or(WG.Bottom,WG.Right)] = '╭', 
    [util.bit_or(WG.Top,WG.Right)] = '╰', 
    [util.bit_or(WG.Bottom,WG.Left)] = '╮', 
    [util.bit_or(WG.Top,WG.Left)] = '╯',
}

WG.BorderSize = {}
for k,v in pairs(WG.Border) do
    WG.BorderSize[k] = #v
end

---@class WindowFrames
---@field from integer
---@field to integer

---@class WindowGroup
local ins = { }

---@type  boolean[][]
ins.frames = {}

---@type integer
ins.curr_focus = 1 

---@type StaticWindow
ins.bg = nil

---@type StaticWindow[]
ins.windows = {}

---@type integer
ins.space = 1

---@type table<integer, StyleCell[]>?
ins.cover_lines = nil

---@param x integer
---@param y integer 
---@param w integer
---@param h integer
---@param space? integer horizontal space
function WG.New__WindowGroup(x,y,w,h, space)
    ---@class WindowGroup
    local wg = util.table_clone(ins)

    x = x - 1
    y = y - 1

    wg.space = space or 1
    space = wg.space

    ---@type boolean[]
    local full = {}
    for _ = 1,w do
        table.insert(full, true)
    end
    table.insert(wg.frames, full)

    for _=2,h-1 do
        ---@type boolean[]
        local t = { [1] = true, [w] = true, }
        table.insert(wg.frames, t)
    end


    table.insert(wg.frames, util.table_clone(full))

    table.insert(wg.frames, {})
    wg.frames[0] = {}


    wg.bg = Window(x,y,w,h)
    wg.bg.focusable = true

    local buf = wg.bg.buf
    wu.block_edit_keys(buf)
    wu.set_only_read(buf)
    vim.api.nvim_set_option_value("buftype", "nofile", {buf=buf})

    wg:refresh()

    return wg
end


---@param x integer
---@param y integer 
---@param w integer
---@param h integer
---@param frame_hide? integer 4bit top bottom left right
---@return StaticWindow
function ins:add_window(x,y,w,h, frame_hide)
    local _x = x+self.bg.rect.x + self.space
    local _y = y+self.bg.rect.y
    local _w = w - self.space*2 - 2
    local _h = h - 2
    local win = Window(_x,_y,_w,_h)

    frame_hide = frame_hide or 0

    table.insert(self.windows, win)

    local y2 = y+h-1
    local x2 = x+w-1

    if util.bit_and(frame_hide , WG.Top) == 0 then
        for i=x,x2 do
            self.frames[y][i] = true
        end
    end

    if util.bit_and(frame_hide , WG.Bottom) == 0 then
        for i=x,x2 do
            self.frames[y2][i] = true
        end
    end

    if util.bit_and(frame_hide , WG.Left) == 0 then
        for i=y+1,y2-1 do
            self.frames[i][x] = true
        end
    end

    if util.bit_and(frame_hide , WG.Right) == 0 then
        for i=y+1,y2-1 do
            self.frames[i][x2] = true
        end
    end

    return win
end

function ins:is_show()
    return self.bg.wnd ~= nil
end

function ins:show()
    self.bg:show()

    for _,w in ipairs(self.windows) do
        w:show()
    end

    self:switch_focus(self.curr_focus)
end

---@param index integer
function ins:switch_focus(index)
    local w = self.windows[index]
    if w then
        w:focus()
        self.curr_focus = index
    end
end

function ins:hide()
    self.bg:hide()
    for _,w in ipairs(self.windows) do
        w:hide()
    end
end

function ins:destroy()
    self.bg:destroy()
    for _,w in ipairs(self.windows) do
        w:hide()
    end

end

local empty = {}

---@param _start? integer
---@param _end? integer
function ins:refresh(_start,_end)
    local frames = self.frames

    local line_styles = {}
    local flines = {}

    local cover_lines = self.cover_lines or empty

    local area = self.bg.rect   
    _start = _start or 1
    _end = _end or area.h
    for i=_start,_end do
        local v = frames[i]
        local strs = {}

        ---@type StyleCell[]
        local cov_line = cover_lines[i] or empty

        local coverId = 1

        local j = 1

        local save_index = 1
        local byte_index = 1

        local cover = cov_line[coverId]
        local indent =  cover and cover.indent or 0

        local style = {}
        while j <= area.w do 

            if cover and indent == 0 then
                table.insert(strs, cover.text)

                if byte_index > save_index then
                    table.insert(style,{
                        _start = save_index,
                        _end = byte_index,
                    })
                end

                table.insert(style,{
                    style = cover.style,
                    _start = byte_index,
                    _end =  byte_index+cover.byte_width
                })

                byte_index = byte_index+cover.byte_width+1
                save_index = byte_index

                j = j + cover.width
                coverId = coverId+1
                cover = cov_line[coverId]
                indent = cover and cover.indent or 0
            else
                local id = util.bit_or(
                (frames[i-1][j] and WG.Top or 0) ,
                (frames[i+1][j] and WG.Bottom or 0) ,
                (v[j-1] and WG.Left or 0) ,
                (v[j+1] and WG.Right or 0))

                if v[j] then
                    table.insert(strs, WG.Border[id])
                    byte_index = byte_index + WG.BorderSize[id]
                else
                    table.insert(strs, " ")
                    byte_index = byte_index + 1
                end
                j = j+1
                
                indent = indent - 1 
            end
        end

        if byte_index > save_index then
            table.insert(style,{
                _start = save_index,
                _end = byte_index,
            })
        end
        table.insert(line_styles, style)
        table.insert(flines,table.concat(strs))
    end

    self.bg:set_modifiable(true)
    self.bg:set_lines(_start, _end, flines)
    for l,v in ipairs(line_styles) do
        self.bg:set_styles(l+_start-1, v)
    end
    self.bg:set_modifiable(false)
end

WG.class = ins
return WG
