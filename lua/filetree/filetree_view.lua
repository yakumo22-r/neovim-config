-- display tree node
local util = require("base_func")
local wu = require "window.window_util"
local wg = require "window.window_group"

local api = vim.api
---@class FT_TreeLines
---@field line string -- show
---@field node FT_Node
---@field list boolean -- direct list

local WTree = 1

local _cell = wu.create_cell


---@class FT_View:WindowGroup
local ins = {}

ins.super = wg.class

---@type FT_Handler
ins.ft_handler = nil

---@type FT_TreeLines[]
ins.lines = {}

function ins:refresh()
    local lines = {}
    for _,v in ipairs(self.lines) do
        table.insert(lines, v.line)
    end


    local wtree = self.windows[WTree]
    wu.set_modifiable(wtree.buf, true)
    wtree:set_lines(1,#lines+1, lines)
    wu.set_modifiable(wtree.buf, false)

    wg.class.refresh(self,1,2)
end

---@param node FT_Node
local function filename_to_line(node)
    if node.type ~= "file" then
        return " "..node.name .. "/"
    end

    return " "..node.name
end

---@param lines FT_TreeLines[]
---@param datas FT_Node[]
local function build_lines(lines,datas,id)
    level = level or 0
    local ca = {}

    local n_id = 1
    local l_id = 1

    local node_num = #datas

    while n_id < node_num do
        local node = datas[n_id]
        local line = lines[l_id]

        if node then
            -- insert new
            if node.line_id == -1 then
                -- insert new
                table.insert(lines,l_id,{
                    line = filename_to_line(node),
                    node = node,
                    list = false,
                })
                l_id = l_id+1
            elseif node.line_id == -2 then
                if line and line.node == node then
                    -- remove one
                    table.remove(line,l_id)
                end
            else
                line.line = filename_to_line(node)
                line.node = node
                l_id = l_id+1
            end

        end
        n_id = n_id+1
    end
end

---@param ft_handler FT_Handler
local function New__FT_View(ft_handler, w,h)
    ---@type FT_View
    v = util.table_connect(wg.New__WindowGroup(1,1,w,h), ins)

    local buf

    local tree_wnd =v:add_window(1,2,w,h-1,wg.Top)
    buf = tree_wnd.buf

    tree_wnd:set_select_window()
    wu.set_only_read(buf)
    wu.set_modifiable(buf,false)
    wu.block_edit_keys(buf)

    build_lines(v.lines, ft_handler.datas)

    v.cover_lines = {
        [1] = {_cell("ss",1), _cell("我操你妈", 1)}
    }

    v:switch_focus(WTree)

    v:refresh()

    return v
end

return New__FT_View
