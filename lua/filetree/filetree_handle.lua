local util = require("base_func")
local uv = vim.loop

---@alias FT_id integer 

---@class FT_Node
---@field path string
---@field type string
---@field name string
---@field is_dir boolean
---@field level integer 0: under root  
---@field line_id integer -2:hide;-1:to show;>0:show
---@field parent? FT_Node 
---@field children? FT_Node[]

---@class FT_Handler
local ins = {}

---@type string
ins.root = ""

---@typeFT_Node[]
ins.datas = {}

-- TODO:
---@param node FT_Node
---@param hide? boolean
function ins:list_dir(node,hide)
    if not node.children then

        local handle =uv.fs_scandir(node.path)
        node.children = {}
        if handle then
            while true do
                local name, type = uv.fs_scandir_next(handle)
                if not name then break end
                table.insert(ins.datas, {
                    type = type,
                    name = name,
                    level = 0,
                    line_id = -1,
                })
            end
        end
    else
        for _,v in node.children do
            if hide then
                v.line_id = -2
            elseif v.line_id == -2 then
                v.line_id = -1
            end
        end
    end
end

-- TODO:
function ins:rename(node, name)
    
end

-- TODO:
function ins:new(node, name, type)
    
end

-- TODO:
function ins:remove(node)
    
end

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
local function New__FT_Handler(root)
    ---@type FT_Handler
    local h = util.table_clone(ins)
    local handle = uv.fs_scandir(root)

    if handle then
        while true do
            local name, type = uv.fs_scandir_next(handle)
            if not name then break end
            table.insert(h.datas, {
                type = type,
                is_dir = type ~= "file",
                name = name,
                level = 0,
                children = {},
                line_id = -1,
            })
        end
    end

    table.sort(h.datas, sort_nodes)
    return h
end

return New__FT_Handler
