vim.cmd("command! ProjectConf lua project_conf:reload()")
vim.cmd("command! CreateProjectConf lua project_conf:create()")
vim.cmd("command! -nargs=* Build lua project_conf:build(<f-args>)")
vim.cmd("command! -nargs=* Run lua project_conf:run(<f-args>)")

project_conf = {}

local template_lua = {}

template_lua.default = [[local conf = {}

conf.terminal = "default" -- system | toggle
-- <internal value>
-- conf.mac         | is mac            (bool)
-- conf.win         | is win            (bool)
-- conf.unix        | is unix           (bool)
-- conf.mac_unix    | is mac or unix    (bool)
-- conf.path        | working path      (string)

-- internal run by neovim

function conf:build(args)
    print("build not implementation")
end

function conf:run(args)
    print("run not implementation")
end

return conf]]

local function load_project_config()
    local current_dir = Tool.get_current_directory()
    local project_config_file = current_dir .. "/.project.lua"
    -- Check if the file exists in the current directory or any parent directory
    while current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
        if Tool.file_exists(project_config_file) then
            local conf = dofile(project_config_file)
            conf:set_path(Tool.get_current_directory())
            conf.path = Tool.get_current_directory()

            conf.mac = vim.fn.has("mac") == 1
            conf.win = vim.fn.has("win32") == 1
            conf.unix = vim.fn.has("unix") == 1
            conf.mac_unix = conf.mac == true or conf.unix == true

            return conf
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
        project_config_file = current_dir .. "/.project.lua"
    end
    print("no .project.lua defined")
end

function project_conf:azure()
    if not self.conf then
        self.conf = load_project_config()
    end
end

function project_conf:reload()
    self.conf = load_project_config()
end

function project_conf:create()
    local project_config_file = Tool.get_current_directory() .. "/.project.lua"

    file = io.open(project_config_file, "w")
    if file then
        file:write(template_lua.default)
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

    res = Tool.get_value(res, self.conf, { ... })
    if res then
        Tool.execute_shell_command(res, self.conf.terminal)
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
    res = Tool.get_value(res, self.conf, { ... })
    if res then
        Tool.execute_shell_command(res, self.conf.terminal)
    end
end

