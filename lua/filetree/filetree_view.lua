-- display tree node
local util = require("base_func")
local wu = require "window.window_util"
local wg = require "window.window_group"

local api = vim.api
---@class FT_TreeLines
---@field line string -- show
---@field node FT_Node
---@field list boolean -- direct list
---@field styles BufStyle[]

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
    local styles = {}
    for _,v in ipairs(self.lines) do
        table.insert(lines, v.line)
        table.insert(styles, v.styles)
    end

    local wtree = self.windows[WTree]
    wu.set_modifiable(wtree.buf, true)
    wtree:set_lines(1,#lines, lines)

    for i,v in ipairs(styles) do
        wtree:set_styles(i, v)
    end

    wu.set_modifiable(wtree.buf, false)

    wg.class.refresh(self,1,1)
end

local icon_dir = ""
local icon_dir_open = ""
local icon_down = "↓"
local icon_right = "→"


---@param node FT_Node
---@return string,BufStyle[]
local function filename_to_line(node)
    if node.type ~= "file" then
        
        local name = string.format("%s %s %s", icon_right, icon_dir, node.name)
        return name,{
            {
                style = "NavicIconsArray",
                _start = 1,
                _end = #name+2
            }
        }
    end

    local icon,hl_group = wu.get_icon_style(node.name)

    ---@type BufStyle[]
    local styles = {
        {
            style = hl_group,
            _start = 3,
            _end = #icon+2,
        }
    }
    return "  "..icon.." "..node.name, styles
end

---@param lines FT_TreeLines[]
---@param datas FT_Node[]
local function build_lines(lines,datas)
    level = level or 0

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
                local l,styles = filename_to_line(node)
                table.insert(lines,l_id,{
                    line = l,
                    node = node,
                    list = false,
                    styles = styles,
                })
                l_id = l_id+1
            elseif node.line_id == -2 then
                if line and line.node == node then
                    -- remove one
                    table.remove(line,l_id)
                end
            else
                local l,styles = filename_to_line(node)
                line.line = l
                line.node = node
                line.styles = styles
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
    local title = _cell(" File Tree ")
    title.indent = math.floor((w-title.width)/2)
    v.cover_lines = {
        [1] = {title}
    }

    v:switch_focus(WTree)

    v:refresh()

    return v
end

return New__FT_View
