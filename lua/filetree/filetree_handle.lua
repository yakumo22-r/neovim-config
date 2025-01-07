local util = require("base_func")

---@type any
local uv = vim.loop

---@alias FT_id integer 

---@class FT_Node
---@field name string
---@field path? string
---@field is_dir boolean
---@field dir_open? boolean
---@field level integer 0: under root  
---@field parent? FT_Node 
---@field children? FT_Node[]

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
}

---@param a FT_Node
---@param b FT_Node
local function sort_nodes(a,b)
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
        path = root,
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
    local level = parent.level+1

    if parent.children == nil then
        scan = parent.path
        children = {}
        parent.children = children
    end

    if scan then
        local handle =uv.fs_scandir(scan)
        if handle then
            while true do
                local name, type = uv.fs_scandir_next(handle)
                if not name then break end

                local node = {
                    is_dir = type ~= "file",
                    name = name,
                    level = level,
                }

                if node.is_dir then
                    node.path = vim.fs.joinpath(scan,name)
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
        self:rename(node,args)
    end
end

---@param node FT_Node
function ins:open_close(node)
    if node.is_dir then
        self:list_dir(node)
        node.dir_open = not node.dir_open
    end
end

---@param node FT_Node
---@param name string
function ins:rename(node, name)
    local origin = vim.fs.joinpath(node.parent.path, node.name)
    local new_name = vim.fs.joinpath(node.parent.path, name)
    local success,err = os.rename(origin, new_name)
    if not success then
        print("rename failed: "..err)
    end
end

-- TODO:
function ins:new(node, name, type)
    
end

-- TODO:
function ins:remove(node)
    
end

FH.FileTreeEvt = FileTreeEvt
return FH
