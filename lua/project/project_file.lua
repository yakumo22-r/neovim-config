---@class PFile
local M = {}

local azure = false
local root

local _name

function M:set_name(name)
    _name = name
end

function M:root_name()
    return _name or ".ykm22_nvim"
end

local wait_use_undo = false

function M:check_use_undo_dir()
    -- run in next frame
    vim.defer_fn(function()
        root = M:get_root()
        if vim.fn.isdirectory(root) == 1 then
            vim.opt.undodir = root .. "/.undo/"
        else
            wait_use_undo = true
        end
    end, 0)
end

function M:get_root()
    if not root then
        local cwd = vim.fn.getcwd()
        local findMax = 3
        local findI = 1
        local find = false

        -- check is .git dir under cwd
        while findI <= findMax do
            local git_dir = cwd .. "/.git"
            local _root = cwd .. "/" .. M:root_name()
            if vim.fn.isdirectory(git_dir) == 1 then
                root = _root
                find = true
                break
            end

            if vim.fn.isdirectory(_root) == 1 then
                root = _root
                find = true
                break
            end

            -- cd ..
            cwd = vim.fn.fnamemodify(cwd, ":h")
            findI = findI + 1
        end

        if not find then
            root = vim.fn.getcwd() .. "/" .. M:root_name()
        end
    end
    return root
end

function M:azure_root()
    root = M:get_root()
    if not azure then
        if vim.fn.isdirectory(root) == 0 then
            vim.fn.mkdir(root, "p")
        end

        if wait_use_undo then
            vim.opt.undodir = root .. "/.undo/"
        end
    end

    return root
end

function M:get_file(name, default)
    -- read file name from cwd/.nvim, if not, write default
    local file = self:azure_root() .. "/" .. name
    if vim.fn.filereadable(file) == 0 then
        local f = io.open(file, "w")
        if f then
            f:write(default or "")
            f:close()
        end
    end

    local f = io.open(file, "r")
    if f then
        local content = f:read("*a")
        f:close()
        return content
    end

    return default
end

function M:get_json(name, default)
    -- read file name from cwd/.nvim, if not, write default
    local content = M:get_file(name, default)

    -- parse json use vim api
    return vim.fn.json_decode(content)
end

function M:get_table(name, default)
    local content = M:get_file(name, default)

    -- run lua code, check error
    local f, err = loadstring(content)
    if not f then
        print("Error loading file " .. name .. ": " .. err)
        return default
    end
    return {}
end

vim.api.nvim_create_user_command("InitProjectFile", function()
    M:azure_root()
end, {})

return M
