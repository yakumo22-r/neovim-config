local util = require("base_func")
local bufu = require("bufutils")
---@type any
local uv = vim.loop

local M = {}

---@class FT_Listener
local ins = {
    success = false,
    ---@type any
    handle = nil,

    ---@type boolean?
    in_time = nil,

    ---@type string[]
    events = {},
}

---@class FT_Dir
---@field open? boolean
---@field path string directory abs path
---@field children? FT_Node[]
---@field cmap? table<string,FT_Node>
---@field lis any fs listener handle

---@class FT_Node
---@field name string
---@field level integer 0: under root
---@field parent FT_Node
---@field dir? FT_Dir

---@param node? FT_Node
---@param view? FT_View
function ins:set_info(node, view)
    self.node = node
    self.view = view
end

---@param node FT_Node
---@param view FT_View
function M.start_listen(node,view)
    ---@type FT_Dir
    local dir = node.dir
    if not dir or dir.lis then
        return
    end
    dir.lis = uv.new_fs_event()

    if not dir.lis then
        vim.notify(string.format("Failed to start_listen, handle is nil. (%s)", dir.path), vim.log.levels.ERROR)
    end

    local es = {}
    local in_time = false

    local success = uv.fs_event_start(dir.lis, dir.path, { recursive = false }, function(err, filename, events)
        if err then
            vim.notify("dir listen Error: " .. err, vim.log.levels.ERROR)
            return
        end

        if events.rename then
            table.insert(es, filename)
            if not in_time then
                in_time = true
                vim.defer_fn(function()
                    in_time = false
                    M.fs_event_callback(node,view,es)
                    es = {}
                end, 200)
            end
        end
    end)

    if not success then
        vim.notify(string.format("Failed to start_listen, unknow error. (%s)", dir.path), vim.log.levels.ERROR)
        uv.close(dir.lis)
        dir.lis = nil
    end
end

---@param node FT_Node
function M.stop_listen(node)
    local dir = node.dir
    if not dir or not dir.lis then
        return
    end
    uv.fs_event_stop(dir.lis)
    uv.close(dir.lis)
    dir.lis = nil
end

---@param a FT_Node
---@param b FT_Node
function M.sort_nodes(a, b)
    local _a = 0
    local _b = 0
    if a.dir and not b.dir then
        _a = 1
    elseif not a.dir and b.dir then
        _b = 1
    else
        return a.name < b.name
    end

    return _a > _b
end

---@param node FT_Node
function M.display_lines(node)
    local line = 0
    local dir = node.dir
    if dir and dir.open then
        for _, child in ipairs(dir.children) do
            line = line + M.display_lines(child) + 1
        end
    end
    return line
end

---@param node FT_Node
function M.find_line(node)
    local line = 0

    ---@type FT_Node
    local parent = node.parent

    while parent do
        line = line + 1
        for _, v in ipairs(parent.dir.children) do
            if v == node then
                break
            end
            line = line + M.display_lines(v) + 1
        end
        node = parent
        parent = node.parent
    end

    return line
end

---@param path string
---@param level? integer
---@param oNode? FT_Node
---@return FT_Node
function M.list_dir(path, level, oNode)
    level = level or 0
    ---@type FT_Node
    local node = oNode or {
        name = vim.fn.fnamemodify(path, ":t"),
        dir = {},
        level = level,
    }
    local oDir = oNode and oNode.dir
    local oCmap = oDir and oDir.cmap
    local dir = node.dir or {}

    dir.path = path
    dir.children = {}
    dir.cmap = {}

    local handle = uv.fs_scandir(path)
    while true do
        local name, type = uv.fs_scandir_next(handle)
        if not name then
            break
        end

        ---@type FT_Node
        local child = {
            dir = (type ~= "file") and {} or nil,
            name = name,
            level = level + 1,
            parent = node,
        }

        if child.dir then
            local oChild = oCmap and oCmap[name]
            if oChild then
                child = oChild
                oCmap[name] = nil
            else
                child.dir.path = vim.fs.abspath(vim.fs.joinpath(path, name))
            end
        end

        table.insert(dir.children, child)
        dir.cmap[name] = child
    end
    table.sort(dir.children, M.sort_nodes)
    if oCmap then
        for _, oChild in pairs(oCmap) do
            -- TODO: clear listen
        end
    end
    return node
end

---@param a FT_Node
---@param b FT_Node
local function rename_node_eq(a, b)
    if a == b then
        return true
    end

    if a.name ~= b.name then
        return false
    end

    if (a.dir and 1) ~= (b.dir and 1) then
        return false
    end

    if a.level ~= b.level then
        return false
    end

    return true
end

---@param dir FT_Dir
---@param oPath string
local function rename_dir(dir, oPath)
    local cwd = vim.fn.getcwd()
    for _, v in ipairs(dir.children) do
        local vDir = v.dir
        if vDir then
            ---@type string
            oPath = vDir.path
            vDir.path = vim.fs.abspath(vim.fs.joinpath(v.parent.dir.path, v.name))
            if vDir.children then
                rename_dir(vDir, oPath)
            end
        else
            local oPath2 = vim.fs.relpath(cwd, vim.fs.joinpath(oPath, v.name))
            local buf = vim.fn.bufnr(oPath2)
            if buf > 0 then
                local nPath = vim.fs.relpath(cwd, vim.fs.joinpath(v.parent.dir.path, v.name))
                if nPath then
                    vim.api.nvim_buf_set_name(buf, nPath)
                end
            end
        end
    end
end

---@param view FT_View
---@param node FT_Node
---@param es string[]
function M.fs_event_callback(node,view, es)
    local dir = node.dir
    if not dir then
        return
    end

    -- local cwd = vim.fn.getcwd()
    ---@type FT_Node?
    local rmNode = nil
    for _, e in ipairs(es) do
        local eNode = dir.cmap[e]
        if eNode then
            -- file/directory removed
            dir.cmap[e] = nil
            rmNode = eNode
            vim.fs.abspath(vim.fs.joinpath(dir.path, e))
            if rmNode.dir and rmNode.dir.lis then
                M.change_dir_listen(rmNode)
            end
        else
            -- file/directory created
            local nPath = vim.fs.abspath(vim.fs.joinpath(dir.path, e))
            local stat = uv.fs_stat(nPath)

            ---@type FT_Node
            local nNode
            if stat then
                if stat.type == "directory" then
                    nNode = M.list_dir(nPath, node.level + 1)
                    local nDir = nNode.dir or {}
                    local rmDir = rmNode and rmNode.dir
                    if rmDir and rmDir.open then
                        local same = true
                        for i, child in ipairs(rmDir.children) do
                            local oNode = nDir.children[i]
                            if not rename_node_eq(oNode, child) then
                                same = false
                                break
                            end
                        end

                        -- TEST:
                        -- check is rename directory
                        if same then
                            nDir.children = rmDir.children
                            rmDir.children = {}
                            nDir.cmap = rmDir.cmap
                            rmDir.cmap = {}
                            rename_dir(nDir, rmDir.path)

                            nDir.open = true
                            M.change_dir_listen(nNode, view)
                        end
                    end

                    nNode.parent = node
                else
                    nNode = {
                        name = e,
                        level = node.level + 1,
                        parent = node,
                    }
                    -- TODO: rename opened buf
                end
                dir.cmap[e] = nNode
            end

            rmNode = nil
        end
    end

    local oLines = M.display_lines(node)
    dir.children = {}
    for _, v in pairs(dir.cmap) do
        table.insert(dir.children, v)
    end
    table.sort(dir.children, M.sort_nodes)
    -- local nLines = M.display_lines(node)

    view:on_node_refresh(node, oLines)
end

---@param node FT_Node
---@param view? FT_View
function M.change_dir_listen(node, view)
    ---@type FT_Dir
    local dir = node.dir or {}

    view = dir.open and view or nil

    if view then
        M.start_listen(node, view)
    else
        M.stop_listen(node)
    end

    if dir.children then
        for _, child in ipairs(dir.children) do
            if child.dir then
                M.change_dir_listen(child, view)
            end
        end
    end
end

---@param node FT_Node
---@param view FT_View
function M.open_dir(node, view)
    local oL = M.display_lines(node)
    M.list_dir(node.dir.path, node.level, node)
    node.dir.open = true
    -- local nL = M.display_lines(node)
    M.change_dir_listen(node, view)
    view:on_node_refresh(node, oL)
end

---@param node FT_Node
---@param view FT_View
function M.close_dir(node, view)
    local oL = M.display_lines(node)
    node.dir.open = false
    -- local nL = M.display_lines(node)
    M.change_dir_listen(node)
    view:on_node_refresh(node, oL)
end

return M
