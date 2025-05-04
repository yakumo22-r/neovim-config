--[[ 
filetree_view 

use multiple windows to show file tree and operations window
[x]fletree
[x]filepath

[ ]type text operation
    [x]rename
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

-- display tree node
local util = require("base_func")
local WU = require("window.window_util")
local WG = require("window.window_group")

local FH = require("filetree.filetree_handle")
local FileTreeEvt = FH.FileTreeEvt

local api = vim.api
---@class FT_TreeLines
---@field line string -- show
---@field node FT_Node
---@field styles BufStyle[]

local WTree = 1
local WTreePath = 2
local WInput = 3

-- filetree view
---@class FT_View:WindowGroup
local ins = {}

ins.super = WG.class

---@type FT_Handler
ins.ft_handler = nil

---@type FT_TreeLines[]
ins.lines = {}

---@type TextInput
ins.textInput = nil

function ins:refresh()
    WG.class.refresh(self, 1)
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

---@param view FT_View
---@param currline integer
---@param node FT_Node
local function find_node_line(view,currline, node)
    for i=currline,1,-1 do
        local line = view.lines[i]
        if line.node == node then
            return i
        end
    end
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

    local icon, hl_group = WU.get_icon_style(node.name)

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

---@param x integer
---@param y integer
---@param w integer
---@param h integer
---@param frame_hide? integer 4bit top bottom left right
---@return StaticWindow
function ins:add_window(x, y, w, h, frame_hide)
    local win = self.super.add_window(self, x, y, w, h, frame_hide)

    win.on_winleave = function()
        vim.schedule(function()
            if not self:is_show() or not win.wnd or self.textInput:is_show() then
                return
            end
            local curr_win = vim.api.nvim_get_current_win()
            for _, window in ipairs(self.windows) do
                print(string.format("WinLeave leave(%s) curr(%s) for(%s)", tostring(win.wnd), tostring(curr_win), tostring(window.wnd)))
                if curr_win == window.wnd then
                    print("WinLeave group stay")
                    return
                end
            end
            self:hide()
        end)
    end

    return win
end

---@param view FT_View
---@param hide? boolean
local function open_dir(view, hide)
    local cursor = api.nvim_win_get_cursor(view.windows[WTree].wnd)
    local line_id = cursor[1]
    local node = view.lines[line_id].node
    view.ft_handler:entry_event(FileTreeEvt.OpenClose, node)
    if node.is_dir then
        if node.dir_open then
            view:refresh_nodes({ node }, line_id, line_id)
            view:insert_nodes(node.children, line_id + 1)
        else
            view:refresh_nodes({ node }, line_id, line_id)
            view:remove_nodes(line_id + 1, line_id + count_children_display(node.children))
        end
    else
        if hide then
            view:hide()
        end
    end
end

-- file tree operation keys
---@param view FT_View
local function bind_keys(view)
    local buf = view.windows[WTree].buf
    WU.bind_key(buf, "<CR>", "<Nop>", "n")
    WU.bind_key(buf, "<CR>", "<Nop>", "v")

    -- open file/dir
    WU.bind_key(buf, "o", function()
        open_dir(view)
    end, "n")

    WU.bind_key(buf, "<CR>", function()
        open_dir(view, true)
    end)

    -- rename file/dir
    WU.bind_key(buf, "r", function()
        local cursor = api.nvim_win_get_cursor(view.windows[WTree].wnd)
        local line_id = cursor[1]
        local node = view.lines[line_id].node

        local callback = function(str)
            view:switch_focus(WTree)
            if not str then
                return
            end

            local err = view.ft_handler:entry_event(FileTreeEvt.Rename, node, str)
            if not err then
                view:refresh_nodes({ node }, line_id, line_id)
            end
        end

        local path
        if node.is_dir then
            -- path = vim.fs.joinpath(node.path)
            -- view.textInput:init(" Rename Path ", callback, node.name)
            vim.notify("can't not rename path", vim.log.levels.WARN)
        else
            path = vim.fs.joinpath(node.parent.path, node.name)
            view.textInput:init(" Rename File ", callback, node.name)
        end
    end, "n")

    WU.bind_key(buf, "a", function ()
        local cursor = api.nvim_win_get_cursor(view.windows[WTree].wnd)
        local line_id = cursor[1]
        local node = view.lines[line_id].node

        local callback = function (text)
            view:switch_focus(WTree)
            if not text then
                return
            end

            local args = {
                name = text,

                ---@type function
                f = nil
            }

            ---@type any
            local rnode = view.ft_handler:newfile(node, args)

            -- refresh node display
            if rnode then
                if rnode.parent then
                    print("currline:", line_id)
                    line_id = find_node_line(view, line_id, rnode)
                    print("findline:", line_id)
                else
                    line_id = 0
                end

                if rnode.dir_open then
                    view:remove_nodes(line_id+1, line_id + count_children_display(rnode.children))
                end

                local ok, err = pcall(args.f)

                if not ok then
                    vim.notify(err, vim.log.levels.ERROR)
                end

                rnode.dir_open = true

                view:refresh_nodes({ rnode }, line_id, line_id)
                view:insert_nodes(rnode.children, line_id + 1)
            end
        end

        if node.is_dir then
            view.textInput:init(" Create File ", callback, node.path.."/")
        else
            view.textInput:init(" Create File ", callback, node.parent.path.."/")
        end
    end)

    -- delete file/dir
end

function ins:show()
    self.bg:show()

    self.windows[WTreePath]:show()
    self.windows[WTree]:show()

    self:switch_focus(WTree)
end

local function get_ft_wh(self, w, h)
    w = w - self.space * 2 - 2
    h = h - 3
    return { w, h }
end

function ins:on_vim_resize(wh)
    local w = wh.w
    local h = wh.h
    self:resize(w, h)
    local ftwh = get_ft_wh(self, w, h)
    self.windows[ftwh]:resize(ftwh[0], ftwh[1])
end

local function set_buf_only_view(bufs)
    if type(bufs) ~= "table" then
        bufs = { bufs }
    end
    for _, buf in ipairs(bufs) do
        WU.set_only_read(buf)
        WU.set_modifiable(buf, false)
        WU.block_edit_keys(buf)
    end
end

---@param ft_handler FT_Handler
local function New__FT_View(ft_handler, w, h)
    ---@type FT_View
    local v = util.table_connect(WG.New__WindowGroup(vim.o.columns - w + 1, 1, w, h), ins)

    -- file tree
    local tree_wnd = v:add_window(1, 2, w, h - 1, WG.NoBorder)

    v.ft_handler = ft_handler

    v.textInput = require("filetree.text_input")()

    -- root path show
    local tree_path = v:add_window(1, 1, w, 3, WG.NoBorder)
    local pathText, pathStyle = WU.short_text(v.ft_handler:root_path(), tree_path.rect.w, WU.StyleVar)
    tree_path:set_lines(1, nil, { pathText })
    tree_path:set_styles(1, { pathStyle })

    tree_wnd:set_select_window()
    set_buf_only_view({
        tree_wnd.buf,
        tree_path.buf,
    })

    bind_keys(v)

    v:insert_nodes(ft_handler.root.children, 1, true)

    local title = WU._cell(" File Tree ")
    title.indent = math.floor((w - title.width) / 2)
    v.cover_lines = {
        [1] = { title },
    }

    -- v:switch_focus(WTree)

    v:refresh()

    return v
end

return New__FT_View
