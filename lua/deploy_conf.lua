vim.cmd("command! DepReload lua deploy_conf:reload()")
vim.cmd("command! -nargs=* DepUpload lua deploy_conf:upload({<f-args>})")
vim.cmd("command! -nargs=* DepUploadAll lua deploy_conf:upload_all({<f-args>})")
vim.cmd("command! DepChoose lua project_conf:create()")
vim.cmd("command! DepList lua project_conf:create()")
vim.cmd("command! -nargs=* DepSwitch lua deploy_conf:switch({<f-args>})")

local function load_project_config()
    local current_dir = Tool.get_current_directory()
    local project_config_file = current_dir .. "/.deploy.lua"
    -- Check if the file exists in the current directory or any parent directory
    while current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
        if Tool.file_exists(project_config_file) then
            local conf = dofile(project_config_file)
            conf.path = current_dir

            conf.mac = vim.fn.has("mac") == 1
            conf.win = vim.fn.has("win32") == 1
            conf.unix = vim.fn.has("unix") == 1
            conf.mac_unix = conf.mac == true or conf.unix == true

            return conf
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
        project_config_file = current_dir .. "/.deploy.lua"
    end
    print("no .deploy.lua defined")
end

local function process_upload(dirs, files, target, path)
    local terminal = require("toggleterm")
    if target.method == "scp" then
        local mkdir_cmd
        for i, d in ipairs(dirs) do
            local c = string.format("mkdir -p %s/%s", target.path, d)
            mkdir_cmd = mkdir_cmd and (mkdir_cmd .. " && " .. c) or c
        end

        if mkdir_cmd then
            Tool.execute_shell_command(string.format('ssh %s "%s"\n', target.server, mkdir_cmd))
        end

        for i, f in ipairs(files) do
            terminal.exec(string.format('scp "%s/%s" %s:%s/%s', path, f, target.server, target.path, f), 101)
        end

        terminal.exec(string.format('echo "upload %d files to %s, all down at %s"',#files , target.server, os.date("%H:%M:%S")))
    end
end

deploy_conf = {}

function deploy_conf:azure()
    if not self.conf or not self.conf.path then
        self:reload()
    end
end

function deploy_conf:reload()
    self.conf = load_project_config()
    for k, v in pairs(self.conf.targets) do
        self.curr_target = v
        break
    end
end

function deploy_conf:upload_all(args)
    self:azure()
    local files, dirs = Tool.traverse_directory(self.conf.path, nil, self.conf.ignores)


    local my_args = {}
    for i,v in ipairs(args) do
        if v == "-mkdir" then
            my_args.mkdir = true
        end
    end
    process_upload(my_args.mkdir and dirs or {}, files, self.curr_target, self.conf.path)
end

function deploy_conf:upload(args)
    self:azure()
    local my_args = {}
    for i,v in ipairs(args) do
        if v == "-list" then
            my_args.list = true
        elseif v == "-d" then
            my_args.d = args[i+1]
        elseif v == "-mkdir" then
            my_args.mkdir = true
        end
    end

    if my_args.list then
        -- upload selected file
    elseif my_args.d then
        local files, dirs = Tool.traverse_directory(self.conf.path .. "/" .. my_args.d,  my_args.d .. "/", self.conf.ignores)
        process_upload(my_args.mkdir and dirs or {}, files, self.curr_target, self.conf.path)
    else
        -- upload current file
        local file = Tool.get_buffer_path(self.conf.path)
        process_upload(my_args.mkdir and { Tool.parent_of_relative(file) } or {}, { file }, self.curr_target, self.conf.path)
    end
end

function deploy_conf:switch(args)
    if not args[1] then
        for k, v in pairs(self.conf.targets) do
            print("switch to " .. k)
            self.curr_target = v
            break
        end
    elseif self.conf.targets[args[1]] then
        print("switch to " .. args[1])
        self.curr_target = self.conf.targets[args[1]]
    else
        print(args[1](" not exists"))
    end
end
