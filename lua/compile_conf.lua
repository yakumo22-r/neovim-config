vim.cmd("command! CompileConf lua compile_conf:reload()")
vim.cmd("command! -nargs=* CreateCompileConf lua compile_conf:create({<f-args>})")
vim.cmd("command! -nargs=* Build lua compile_conf:build(<f-args>)")
vim.cmd("command! -nargs=* Run lua compile_conf:run(<f-args>)")

compile_conf = {}

local tempate_conf = {}

tempate_conf.default = [[local conf = {}
-- <internal value>
-- conf.mac         | is mac            (bool)
-- conf.win         | is win            (bool)
-- conf.unix        | is unix           (bool)
-- conf.mac_unix    | is mac or unix    (bool)
-- conf.path        | working path      (string)

-- internal run by neovim

function conf:build(args)
    print("build not_implementation")
end

conf.run.cmd = "echo run_no_inplementation"
conf.run.terminal = "default" -- system | toggle


return conf]]


function compile_conf:get_value(t, ...)
    if type(t) == "function" then
        return t(self.conf, ...)
    end
    return t.cmd,t.terminal
end

function compile_conf:azure()
    if not self.conf then
        self:reload()
    end
end

function compile_conf:reload()
    self.conf = Tool.load_project_conf("compile")
    self.conf.T = require("compile_tool")
end

function compile_conf:create(args)
    local tname = "default"
    for i,v in ipairs(args) do
        if v=="-t" then
            tname = args[i+1]
        end
    end

    if tempate_conf.tname then
        Tool.create_project_conf("compile", tempate_conf[tname])
    else
        print("invaid compile conf name: ".. tname)
        Tool.create_project_conf("compile", tempate_conf.default)
    end
end

function compile_conf:build(name, ...)
    self:azure()
    local tbl
    if name and name ~= "d" and name ~= "default" then
        tbl = self.conf["build_" .. name]
        if not tbl then
            print(name .. " not defined")
            return
        end
    else
        tbl = self.conf.build
        if not tbl then
            print("build not defined")
            return
        end
    end

    local cmd,terminal = self:get_value(tbl, { ... })
    if cmd then
        Tool.execute_shell_command(cmd, terminal)
    end
end

function compile_conf:run(name, ...)
    self:azure()
    local tbl
    if name and name ~= "d" and name ~= "default" then
        local tbl = self.conf["run_" .. name]
        if not tbl then
            print(name .. " not defined")
            return
        end
    else
        tbl = self.conf.run
        if not tbl then
            print("run not defined")
            return
        end
    end
    local cmd,terminal = self:get_value(tbl, { ... })
    if cmd then
        Tool.execute_shell_command(cmd, self.conf.terminal)
    end
end

