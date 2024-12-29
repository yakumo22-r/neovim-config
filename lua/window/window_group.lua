require("base_func")
local wu = require "window.window_util"
local Window = require "window.window"

local WG = {}

WG.Border = {
    [0]='•',[0011] = '─', [0111] = '┬', [1011] = '┴', [1100] = '│', [1111] = '┼', [1110] = '┤', [1101] = '├', [0101] = '╭', [1001] = '╰', [0110] = '╮', [1010] = '╯',
}

---@class WindowFrames
---@field from integer
---@field to integer

---@class WindowGroup
local ins = {

    ---@type  boolean[][]
    frames = {},

    ---@type StaticWindow
    bg = {},

    ---@type StaticWindow[]
    windows = {},

    ---@type integer
    space = 1,
}


---@param x integer
---@param y integer 
---@param w integer
---@param h integer
---@return StaticWindow
function ins:add_window(x,y,w,h)
    local _x = x+self.bg.rect.x + self.space
    local _y = y+self.bg.rect.y
    local _w = w - self.space*2 - 2
    local _h = h - 2
    local win = Window(_x,_y,_w,_h)

    table.insert(self.windows, win)

    for i=x,w do
        self.frames[y][i] = true
        self.frames[h][i] = true
    end

    for i=y+1,h-1 do
        self.frames[i][x] = true
        self.frames[i][w] = true
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

---@param lines? string[] cover_string
function ins:refresh(lines)

    local frames = self.frames
    wu.set_modifiable(self.bg.buf, true)
    local flines = {}

    
    local area = self.bg.rect   
    for i=1,area.h do
        local v = frames[i]
        local cs = {}
        for j=1,area.w do
            local id = 0

            if frames[i-1][j] then id = id + 1000 end
            if frames[i+1][j] then id = id + 100 end
            if v[j-1] then id = id + 10 end
            if v[j+1] then id = id + 1 end

            if v[j] then
                table.insert(cs, WG.Border[id])
            else
                table.insert(cs, " ")
            end

        end

        table.insert(flines,table.concat(cs))
    end

    self.bg:set_lines(1, area.h, flines)

    wu.set_modifiable(self.bg.buf, false)
    -- for _,f in ipairs(self.frames) do
    -- end

end

---@param x integer
---@param y integer 
---@param w integer
---@param h integer
---@param space? integer horizontal space
function WG.New__WindowGroup(x,y,w,h, space)
    ---@class WindowGroup
    local wg = table.clone(ins)

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


    table.insert(wg.frames, table.clone(full))

    table.insert(wg.frames, {})
    wg.frames[0] = {}


    wg.bg = Window(x,y,w,h)
    local buf = wg.bg.buf
    wu.block_edit_keys(buf)
    wu.set_only_read(buf)
    vim.api.nvim_set_option_value("buftype", "nofile", {buf=buf})

    wg:refresh()

    return wg
end

return WG
