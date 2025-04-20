--[[ 
filetree_view 

use multiple windows to show file tree and operations window
[x]fletree
[ ]filepath

[ ]type text operation
    [ ]rename
    [ ]newfile

[ ]move
[ ]copy
[ ]delete

[ ]file groups
    [ ] auto groups by git
[ ]multi selected operation
    [ ] add to group
    [ ] delete
    [ ] move
[ ] custom operation

[ ] be a plugins

[ ] show as buffer

[ ] sftp interface
]]


--]]

-- display tree nod
local util = require("base_func")
local wu = require("window.window_util")
local wg = require("window.window_group")

local FH = require("filetree.filetree_handle")
local FileTreeEvt = FH.FileTreeEvt

local api = vim.api
---@class FT_TreeLines
---@field line string -- show
---@field node FT_Node
---@field styles BufStyle[]

local WTree = 1
local WInput = 2

local _cell = wu.create_cell

---@class FT_View:WindowGroup
local ins = {}

ins.super = wg.class

---@type FT_Handler
ins.ft_handler = nil

---@type FT_TreeLines[]
ins.lines = {}

function ins:refresh()
    wg.class.refresh(self, 1)
end

---@param nodes FT_Node[]
local function count_children_display(nodes)
    local count = 0
    for _, v in ipairs(nodes) do
        if v.is_dir and v.dir_open then
            count = count + count_children_display(v.children)
        end
        count = count + 1
    end
    return count
end

---@param node FT_Node
---@return string,BufStyle[]
local function filename_to_line(node)
    local fill = string.rep("  ", node.level)
    local fill_len = #fill

    if node.is_dir then
        local icon1 = node.dir_open and "↓" or "→"
        local icon2 = node.dir_open and "" or ""
        local name = string.format("%s%s %s %s", fill, icon1, icon2, node.name)
        return name,
            {
                {
                    style = "NavicIconsArray",
                    _start = 1,
                    _end = #name + 1,
                },
            }
    end

    local icon, hl_group = wu.get_icon_style(node.name)

    ---@type BufStyle[]
    local styles = {
        {
            style = hl_group,
            _start = fill_len + 2,
            _end = fill_len + 2 + #icon,
        },
    }
    local name = string.format("%s  %s %s", fill, icon, node.name)
    return name, styles
end

---@param datas FT_Node[]
---@param _start integer
---@param _end integer
function ins:refresh_nodes(datas, _start, _end)
    local tree = self.windows[WTree]

    local lines = {}
    local styles = {}

    for i = _start, _end do
        local node = datas[i - _start + 1]
        local line = self.lines[i]

        if node then
            local l, style = filename_to_line(node)
            line.node = node
            line.line = l
            line.styles = styles
            table.insert(lines, l)
            table.insert(styles, style)
        else
            break
        end
    end

    tree:set_modifiable(true)
    tree:set_lines(_start, _start + #lines - 1, lines)
    for i, v in ipairs(styles) do
        tree:set_styles(_start + i - 1, v)
    end
    tree:set_modifiable(false)
end

---@param datas FT_Node[]
---@param _start integer
---@param first? boolean
---@param sub? boolean
---@param lines? string[]
---@param styles? BufStyle[][]
function ins:insert_nodes(datas, _start, first, sub, lines, styles)
    local tree = self.windows[WTree]
    lines = lines or {}
    styles = styles or {}

    local line_id = _start

    local i = 1
    while true do
        local node = datas[i]
        if node then
            local l, style = filename_to_line(node)
            ---@type FT_TreeLines
            local tline = {
                line = l,
                node = node,
                styles = style,
            }
            table.insert(self.lines, line_id, tline)
            table.insert(lines, l)
            table.insert(styles, style)

            if node.dir_open then
                line_id = self:insert_nodes(node.children, line_id + 1, false, true, lines, styles)
            else
                line_id = line_id + 1
            end
        else
            break
        end

        i = i + 1
    end

    if not sub then
        tree:set_modifiable(true)
        if first then
            tree:set_lines(_start, _start, lines)
        else
            tree:set_lines(_start, _start - 1, lines)
        end
        for j, v in ipairs(styles) do
            tree:set_styles(_start + j - 1, v)
        end
        tree:set_modifiable(false)
    end

    return line_id
end

---@param _start integer
---@param _end integer
function ins:remove_nodes(_start, _end)
    for i = _end, _start, -1 do
        table.remove(self.lines, i)
    end

    local tree = self.windows[WTree]
    tree:set_modifiable(true)
    tree:set_lines(_start, _end, {})
    tree:set_modifiable(false)
end

-- file tree operation keys
---@param view FT_View
local function bind_keys(view)
    local buf = view.windows[WTree].buf
    wu.bind_key(buf, "<CR>", "<Nop>", "n")
    wu.bind_key(buf, "<CR>", "<Nop>", "v")

    -- open file/dir
    wu.bind_key(buf, "o", function()
        local cursor = api.nvim_win_get_cursor(view.windows[WTree].wnd)
        local line_id = cursor[1]
        local node = view.lines[line_id].node
        v.ft_handler:entry_event(FileTreeEvt.OpenClose, node)
        if node.is_dir then
            if node.dir_open then
                view:refresh_nodes({ node }, line_id, line_id)
                view:insert_nodes(node.children, line_id + 1)
            else
                view:refresh_nodes({ node }, line_id, line_id)
                view:remove_nodes(line_id + 1, line_id + count_children_display(node.children))
            end
        end
    end, "n")

    -- rename file/dir
    wu.bind_key(buf, "r", function()
        local cursor = api.nvim_win_get_cursor(view.windows[WTree].wnd)
        local line_id = cursor[1]
        local node = view.lines[line_id].node
        print(node.name)
        -- v.ft_handler:entry_event(FileTreeEvt.Rename, node)
        -- if not node.is_dir then
        --     v:refresh_nodes({node}, line_id, line_id)
        -- end
    end, "n")

    -- delete file/dir
end

function ins:show()
    self.bg:show()

    local wtree = self.windows[WTree]
    wtree:show()

    self:switch_focus(WTree)
end

local function get_ft_wh(self, w,h)
    w = w - self.space*2 - 2
    h = h-3
    return {w,h}
end

function ins:on_vim_resize(wh)
    local w = wh.w
    local h = wh.h
    self:resize(w, h)
    local ftwh = get_ft_wh(self, w,h)
    self.windows[ftwh]:resize(ftwh[0],ftwh[1])
end

---@param ft_handler FT_Handler
local function New__FT_View(ft_handler, w, h)
    ---@type FT_View
    v = util.table_connect(wg.New__WindowGroup(1, 1, w, h), ins)

    local buf

    local tree_wnd = v:add_window(1, 2, w, h - 1, wg.NoBorder)
    buf = tree_wnd.buf

    v.ft_handler = ft_handler

    tree_wnd:set_select_window()
    wu.set_only_read(buf)
    wu.set_modifiable(buf, false)
    wu.block_edit_keys(buf)

    bind_keys(v)

    v:insert_nodes(ft_handler.root.children, 1, true)

    local title = _cell(" File Tree ")
    title.indent = math.floor((w - title.width) / 2)
    v.cover_lines = {
        [1] = { title },
    }

    v:switch_focus(WTree)

    v:refresh()

    return v
end

return New__FT_View
