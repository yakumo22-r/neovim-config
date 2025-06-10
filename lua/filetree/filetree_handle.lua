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
    local last_char = path:sub(path_len)
    while last_char == '/' or last_char == '\\' do
        trim_end = trim_end + 1
        last_char = path:sub(path_len - trim_end, 1)
    end

    local filename = nil
    if trim_end > 0 then
        path = path:sub(1, path_len - trim_end)
    else
        filename = vim.fn.fnamemodify(path, ":t")
        path = vim.fn.fnamemodify(path, ":h")
    end


    if not filename and path == node.dir.path then
        vim.notify("Nothing Create!!!", vim.log.levels.WARN)
        -- "no need to create"
        return
    end

    -- not under root
    local root_path = node.dir.path
    local sub_char = path:sub(#root_path+1,1)
    if path:sub(1,#root_path) ~= root_path and (sub_char == '/' or sub_char == '\\') then
        vim.notify(string.format("create file/dir must under %d",node.dir.path), vim.log.levels.ERROR)
        return
    end

    local need_mkdir = false
    -- if true then return end
    if not filename or vim.fn.fnamemodify(oPath, ":h") ~= root_path then
        need_mkdir = true
    end

    -- create path
    local ok,err = pcall(function ()
        if need_mkdir then
            vim.fn.mkdir(path, "p")
        end

        -- create file
        if filename then
            local file = io.open(oPath, "r")
            if not file then
                file = io.open(oPath, "w")
                if file then
                    file:write("")
                    file:close()
                else
                    vim.notify("Create file error -> " .. oPath, vim.log.levels.ERROR)
                end
            else
                file:close()
                vim.notify("Filename already exsist: " .. oPath, vim.log.levels.ERROR)
            end
        end
    end)

    if not ok then
        vim.notify("Create file/dir error: ".. err, vim.log.levels.ERROR)
    end
end

-- TODO:
---@param node FT_Node
function ins:remove(node) 
    local dir = node.parent.dir or {}
    local absolute_path = vim.fs.joinpath(dir.path, node.name)
    if vim.fn.filereadable(absolute_path) == 0 and vim.fn.isdirectory(absolute_path) == 0 then
        vim.notify("Path does not exist: " .. absolute_path, vim.log.levels.ERROR)
        return
    end

    local success
    if vim.fn.isdirectory(absolute_path) == 1 then
        success = vim.fn.delete(absolute_path, "rf") == 0 -- delete directory
    else
        success = vim.fn.delete(absolute_path) == 0 -- delete file
    end

    if success then
        vim.notify("Deleted: " .. absolute_path, vim.log.levels.INFO)
    else
        vim.notify("Failed to delete: " .. absolute_path, vim.log.levels.ERROR)
    end
end
return FH
