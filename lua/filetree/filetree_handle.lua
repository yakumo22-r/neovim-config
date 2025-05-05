local util = require("base_func")
local FE = require("filetree.filetree_event")

---@type any
local uv = vim.loop

---@alias FT_id integer

local FH = {}

---@class FT_Handler
local ins = {}

---@type FT_Node
ins.root = nil

---@param root string
function FH.New__FT_Handler(root)
    ---@type FT_Handler
    local h = util.table_clone(ins)
    h.root = FE.list_dir(vim.fs.abspath(root), -1)
    h.root.dir.open = true
    return h
end

function ins:entry_event(e, node, args)
end

---@return string
function ins:root_path()
    return self.root.dir.path
end

-- ---@param node FT_Node
-- ---@param old_path string
-- local function dir_refresh(node, old_path)
--     local children = node.children or {}
--     for _, child in ipairs(children) do
--         if child.is_dir then
--             ---@type string
--             local path = child.path
--             child.path = vim.fs.joinpath(node.path, child.name)
--             dir_refresh(child, path)
--         else
--             local path = vim.fs.joinpath(old_path, child.name)
--             path = vim.fs.relpath(vim.fn.getcwd(), path) or path
--             local buf = vim.fn.bufnr(path)
--             if buf >= 0 then
--                 path = vim.fs.joinpath(child.parent.path, child.name)
--                 path = vim.fs.relpath(vim.fn.getcwd(), path) or path
--                 vim.api.nvim_buf_set_name(buf, path)
--                 vim.api.nvim_buf_call(buf, function()
--                     vim.cmd("edit!")
--                 end)
--             end
--         end
--     end
-- end

---@param node FT_Node
---@param name string
function ins:rename(node, name)
    local dir = node.parent.dir or {}
    local origin = vim.fs.joinpath(dir.path, node.name)
    local new_name = vim.fs.joinpath(dir.path, name)
    local success, err = os.rename(origin, new_name)
    if not success then
        vim.notify("Rename failed -> " .. err, vim.log.levels.ERROR)
        return true
    end

    if dir then
        -- node.name = name
        -- ---@type string
        -- local path = node.path
        -- node.path = vim.fs.joinpath(node.parent.path, name)
        -- dir_refresh(node, path)
    else
--         local path = vim.fs.joinpath(node.parent.path, node.name)
--         path = vim.fs.relpath(vim.fn.getcwd(), path) or path

--         local buf = vim.fn.bufnr(path)
--         if buf >= 0 then
--             path = vim.fs.joinpath(node.parent.path, name)
--             path = vim.fs.relpath(vim.fn.getcwd(), path) or path
--             vim.api.nvim_buf_set_name(buf, path)
--             vim.api.nvim_buf_call(buf, function()
--                 vim.cmd("edit!")
--             end)
--         end
--         node.name = name
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

return FH
