---@class ykm22.nvim.ProjectFile
local M = {}

local azure = false
local root

local _name

function M.set_name(name)
    _name = name
end

function M.root_name()
    return _name or ".ykm22_nvim"
end

local wait_use_undo = false

---@type fun(root:string) []
_use_cmds = {}

---@param e fun(root:string)
function M.use_project_dir(e)
    if azure then
        e(M.get_root())
    else
        table.insert(_use_cmds)
    end
end

function M.get_root()
    if not root then
        local cwd = vim.fn.getcwd()
        local findMax = 3
        local findI = 1
        local find = false

        -- check is .git dir under cwd
        while findI <= findMax do
            local git_dir = cwd .. "/.git"
            local _root = cwd .. "/" .. M.root_name()
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
            root = vim.fn.getcwd() .. "/" .. M.root_name()
        end
    end
    return root
end

---@return string
function M.azure_root()
    root = M.get_root()
    if not azure then
        if vim.fn.isdirectory(root) == 0 then
            vim.fn.mkdir(root, "p")
            for _, e in ipairs(_use_cmds) do
                e(root)
            end
        end
        azure = true
    end
    return root
end

---@param name string
---@param default string?
---@param default_file string?
function M.get_file(name, default, default_file)
    if not azure then
        vim.notify("Project dir not initialized. Please run :InitProjectFile", vim.log.levels.WARN)
        return
    end
    -- read file name from cwd/.nvim, if not, write default
    local file = M.azure_root() .. "/" .. name
    if vim.fn.filereadable(file) == 0 and (default or default_file) then
        local f = io.open(file, "w")
        if f then
            if not default and default_file then
                local f1 = io.open(default_file, "r")
                if f1 then
                    default = f1:read("*a")
                    f1:close()
                end
            end
            f:write(default)
            f:close()
        end
    end

    local f = io.open(file, "r")
    if f then
        local content = f:read("*a")
        f:close()
        return content, file
    end

    return default, file
end

---@param use_cmds fun(root:string) []
function M.setup(use_cmds)
    for _, e in ipairs(use_cmds) do
        table.insert(_use_cmds, e)
    end

    vim.api.nvim_create_user_command("InitProjectFile", function()
        M.azure_root()
    end, {})

    vim.schedule(function()
        root = M.get_root()
        if vim.fn.isdirectory(root) == 1 then
            azure = true
            for _, e in ipairs(_use_cmds) do
                e(root)
            end
            _use_cmds = false
        end
    end)
end

return M
