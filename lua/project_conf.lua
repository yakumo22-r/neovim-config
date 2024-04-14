local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Function to load and execute Lua code from a file
local function load_file_and_execute(file_path)
    if file_exists(file_path) then
        return loadfile(file_path)
    end
end

local function get_current_directory()
    return vim.fn.expand("%:p:h")
end

-- Define the function to load project configuration
local function load_project_config()
    local current_dir = get_current_directory()
    local project_config_file = current_dir .. "/.project.lua"
    -- Check if the file exists in the current directory or any parent directory
    while current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
        if file_exists(project_config_file) then
            local conf = dofile(project_config_file)
            conf:set_path(get_current_directory())
            return conf
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
        project_config_file = current_dir .. "/.project.lua"
    end
    print("no .project.lua defined")
end

local function execute_shell_command(command)
    vim.api.nvim_command("!" .. command)
end

local function get_cmd(self, c, args)
     if type(c) == "function" then
        return c(self, args)
    elseif type(c) == "string" then
        return c
    end
end

project_conf = {}

function project_conf:azure()
    if not self.conf then
        self.conf = load_project_config()
    end
end

function project_conf:reload()
    self.conf = load_project_config()
end

function project_conf:create()
    local project_config_file = get_current_directory() .. "/.project.lua"
    local default_table = [[local conf = {}

-- internal run by neovim
function conf:set_path(path) self.path = path end

function conf:build(args)
    print("build not implementation")
end

function conf:run(args)
    print("run not implementation")
end

return conf]]

    file = io.open(project_config_file, "w")
    if file then
        file:write(default_table)
        file:close()
    else
        print("cannot open file for writting: " .. project_config_file)
    end
end

function project_conf:build(name, ...)
    self:azure()
    local res
    if name and name ~= "d" and name ~= "default" then
        res = self.conf["build_" .. name]
        if not res then
            print(name .. " not defined")
            return
        end
    else
        res = self.conf.build
        if not res then
            print("build not defined")
            return
        end
    end

    res = get_cmd(self.conf, res, {...})
    if res then
        execute_shell_command(res)
    end
end

function project_conf:run(name, ...)
    self:azure()
    local res
    if name and name ~= "d" and name ~= "default" then
        local res = self.conf["run_" .. name]
        if not res then
            print(name .. " not defined")
            return
        end
    else
        res = self.conf.run
        if not res then
            print("run not defined")
            return 
        end
    end
    res = get_cmd(self.conf, res, {...})
    if res then
        execute_shell_command(res)
    end
end

vim.cmd("command! ProjectConf lua project_conf:reload()")
vim.cmd("command! CreateProjectConf lua project_conf:create()")
vim.cmd("command! -nargs=* Build lua project_conf:build(<f-args>)")
vim.cmd("command! -nargs=* Run lua project_conf:run(<f-args>)")
