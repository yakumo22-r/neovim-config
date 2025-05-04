local util = require("base_func")

---@type any
local uv = vim.loop

---@alias FT_id integer

---@class FT_Node
---@field name string
---@field path? string directory abs path
---@field is_dir boolean
---@field dir_open? boolean
---@field level integer 0: under root
---@field parent? FT_Node
---@field children? FT_Node[]
---@field cmap? table<string, FT_Node>

local FH = {}

---@class FT_Handler
local ins = {}

---@type FT_Node
ins.root = nil

---@enum FileTreeEvt
local FileTreeEvt = {
    OpenClose = 1,
    Delete = 2,
    Rename = 3,
    Newfile = 4,
}

---@param node FT_Node
local function build_cmap(node)
    if node.children and node.cmap == nil then
        node.cmap = {}
        for _, child in ipairs(node.children) do
            node.cmap[child.name] = child
        end
    end
end

---@param node FT_Node
---@return table<string,FT_Node>
local function cmap(node)
    build_cmap(node)
    return node.cmap or {}
end

---@param a FT_Node
---@param b FT_Node
local function sort_nodes(a, b)
    local _a = 0
    local _b = 0
    if a.is_dir and not b.is_dir then
        _a = 1
    elseif not a.is_dir and b.is_dir then
        _b = 1
    else
        return a.name < b.name
    end

    return _a > _b
end

---@param root string
function FH.New__FT_Handler(root)
    ---@type FT_Handler
    local h = util.table_clone(ins)
    h.root = {
        path = vim.fs.abspath(root),
        level = -1,
        name = "",
        is_dir = true,
        dir_open = true,
    }

    h:list_dir(h.root)
    return h
end

---@param parent FT_Node
function ins:list_dir(parent)
    ---@type FT_Node[]
    local children = nil
    local scan = nil
    local level = parent.level + 1

    if parent.children == nil then
        scan = parent.path
        children = {}
        parent.children = children
    end

    if scan then
        local handle = uv.fs_scandir(scan)
        if handle then
            while true do
                local name, type = uv.fs_scandir_next(handle)
                if not name then
                    break
                end

                local node = {
                    is_dir = type ~= "file",
                    name = name,
                    level = level,
                }

                if node.is_dir then
                    node.path = vim.fs.abspath(vim.fs.joinpath(scan, name))
                end

                if children then
                    node.parent = parent
                    table.insert(children, node)
                end
            end
        end

        if children then
            table.sort(children, sort_nodes)
        end
    end
end

---@param e FileTreeEvt
---@param node FT_Node
---@param args any
function ins:entry_event(e, node, args)
    if e == FileTreeEvt.OpenClose then
        self:open_close(node)
    elseif e == FileTreeEvt.Rename then
        return self:rename(node, args)
    elseif e == FileTreeEvt.Newfile then
        return self:newfile(node, args)
    end
end

---@param node FT_Node
function ins:open_close(node)
    if node.is_dir then
        self:list_dir(node)
        node.dir_open = not node.dir_open
    else
        local path = vim.fs.joinpath(node.parent.path, node.name)
        YKM22.bufu.open_file(vim.fs.relpath(vim.fn.getcwd(), path) or path)
    end
end

---@return string
function ins:root_path()
    return self.root.path
end

---@param node FT_Node
---@param old_path string
local function dir_refresh(node, old_path)
    local children = node.children or {}
    for _, child in ipairs(children) do
        if child.is_dir then
            ---@type string
            local path = child.path
            child.path = vim.fs.joinpath(node.path, child.name)
            dir_refresh(child, path)
        else
            local path = vim.fs.joinpath(old_path, child.name)
            path = vim.fs.relpath(vim.fn.getcwd(), path) or path
            local buf = vim.fn.bufnr(path)
            if buf >= 0 then
                path = vim.fs.joinpath(child.parent.path, child.name)
                path = vim.fs.relpath(vim.fn.getcwd(), path) or path
                vim.api.nvim_buf_set_name(buf, path)
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("edit!")
                end)
            end
        end
    end
end

---@param node FT_Node
---@param name string
function ins:rename(node, name)
    local origin = vim.fs.joinpath(node.parent.path, node.name)
    local new_name = vim.fs.joinpath(node.parent.path, name)
    local success, err = os.rename(origin, new_name)
    if not success then
        vim.notify("Rename failed -> " .. err, vim.log.levels.ERROR)
        return true
    end

    if node.is_dir then
        -- node.name = name
        -- ---@type string
        -- local path = node.path
        -- node.path = vim.fs.joinpath(node.parent.path, name)
        -- dir_refresh(node, path)
    else
        local path = vim.fs.joinpath(node.parent.path, node.name)
        path = vim.fs.relpath(vim.fn.getcwd(), path) or path

        local buf = vim.fn.bufnr(path)
        if buf >= 0 then
            path = vim.fs.joinpath(node.parent.path, name)
            path = vim.fs.relpath(vim.fn.getcwd(), path) or path
            vim.api.nvim_buf_set_name(buf, path)
            vim.api.nvim_buf_call(buf, function()
                vim.cmd("edit!")
            end)
        end
        node.name = name
    end
end

---@param node FT_Node
function ins:newfile(node, args)

    local oPath =vim.fs.abspath(args.name) 

    local path = oPath

    -- maybe only create path 
    local path_len = #path
    local trim_end = 0
    local last_char = path[path_len]
    while last_char == '/' or last_char == '\\' do
        trim_end = trim_end + 1
        last_char = path[path_len - trim_end]
    end

    local filename = nil
    if trim_end > 0 then
        path = path:sub(1, path_len - trim_end)
    else
        filename = vim.fn.fnamemodify(path, ":t")
        path = vim.fn.fnamemodify(path, ":h")
    end


    if not filename and path == node.path then
        vim.notify("Nothing Create!!!", vim.log.levels.WARN)
        -- "no need to create"
        return
    end

    if not node.is_dir then
        ---@type FT_Node
        node = node.parent
    end

    print("new file", oPath, filename, path, node.path)

    -- not under root
    local root_path = self:root_path()
    if path:sub(1,#root_path) ~= root_path then
        vim.notify("create file/dir must under root!!!", vim.log.levels.ERROR)
    end

    local relPath = path:sub(#root_path+1)
    relPath:find('/')

    -- check need to create path 
    local rnode = node
    local baseParent = path
    local dirname = vim.fn.fnamemodify(path, ":t")
    local parent = baseParent
    ---@type FT_Node[]
    local dir_nodes = {}

    while rnode and rnode.path ~= parent do
        table.insert(dir_nodes, {
            is_dir = true,
            name = dirname,
            path = parent,
        })
        rnode = rnode.parent or rnode
        parent = vim.fn.fnamemodify(parent, ":h")
    end

    node = rnode

    -- create path
    args.f = function ()
        if dir_nodes[1] then
            print("???")
            self:list_dir(rnode)
            rnode.dir_open = true
            vim.fn.mkdir(baseParent, "p")
            local len = #dir_nodes
            local last = dir_nodes[len]

            table.insert(rnode.children, last)
            table.sort(rnode.children, sort_nodes)
            last.level = rnode.level + 1

            for i=1,len do
                local dirnode = dir_nodes[i]
                dirnode.parent = dir_nodes[i+1] or rnode
                dirnode.level = last.level + (len-i)
                local child = dir_nodes[i-1]
                dirnode.children = child and { child } or {}
                dirnode.dir_open = true
            end

            node = dir_nodes[1]
        end

        args.new_node = node
        -- create file
        if not node.children then
            self:list_dir(node)
        end
        if filename then
            local file = io.open(oPath, "r")
            if not file then
                file = io.open(oPath, "w")
                if file then
                    file:write("")
                    file:close()

                    print("create file success", oPath)
                    table.insert(node.children, {
                        name = filename,
                        is_dir = false,
                        level = node.level+1,
                        parent = node,
                    })
                    table.sort(node.children, sort_nodes)
                else
                    assert(false, "create file error: " .. oPath)
                end
            else
                file:close()
                assert(false, "filename already exsist: " .. oPath)
            end
        end
    end

    return rnode
end

-- TODO:
function ins:remove(node) end

FH.FileTreeEvt = FileTreeEvt
return FH
