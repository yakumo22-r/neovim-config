vim.cmd("command! DepReload lua deploy_conf:reload()")
vim.cmd("command! -nargs=* DepUpload lua deploy_conf:upload({<f-args>})")
vim.cmd("command! -nargs=* DepUploadAll lua deploy_conf:upload_all({<f-args>})")
vim.cmd("command! CreateDepConf lua deploy_conf:create()")
--vim.cmd("command! DepChoose lua project_conf:create()")
--vim.cmd("command! DepList lua project_conf:create()")
vim.cmd("command! -nargs=* DepSwitch lua deploy_conf:switch({<f-args>})")

local template = [[return {
    localPath = "/",
    targets = {
        target = {
            method = "sftp",
            server = "1.2.3.4",
            user = "root",
            pasword = "******",
            system = "linux",
            path = "/home/prod/server",
        },
    },
    ignores = {
        ".ykm.nvim.proj/",
        ".git/",
        ".tmp/",
    },
}
]]

local temp_deploy_path = ".ykm.nvim.proj/.temp_deploy_path"
local function process_upload(dirs, files, target, path)
    local terminal = require("toggleterm")
    if target.method == "scp" then
        local temp_path = Tool.create_directory(path, temp_deploy_path)
        local sub_root = {}
        for i, d in ipairs(dirs) do
            if string.find(d, "/") == nil then
                table.insert(sub_root, d)
            end
            Tool.create_directory(temp_path, d)
        end

        for i, d in ipairs(sub_root) do
            terminal.exec(string.format('scp -r "%s/%s" %s:%s', temp_path, d, target.server, target.path), 101)
        end

        terminal.exec(string.format('rm -r "%s"', temp_path), 101)

        for i, f in ipairs(files) do
            terminal.exec(string.format('scp "%s/%s" %s:%s/%s', path, f, target.server, target.path, f), 101)
        end

        terminal.exec(string.format('echo "upload %d files to %s, all down at %s"', #files, target.server, os.date("%H:%M:%S")))
    elseif target.method == "sftp" then
        local sftp = require("sftp")
        sftp:init()
        print("login to " .. target.server .. "...")
        vim.schedule(function()
            local c
            c = sftp:create_conection(target.server, target.port, target.username, target.password)
            if c then
                print("login to " .. target.server .. " success")
                for i, f in ipairs(files) do
                    local rc, rmsg = c:upload_file(string.format("%s/%s", path, f), string.format("%s/%s", target.path, f))
                    print(string.format("upload %d: %s  %s code: %d", i, f, rc == 0 and "success" or (rmsg or "failed"), rc))
                end
                print(string.format('upload %d files to %s, all down at %s"', #files, target.server, os.date("%H:%M:%S")))
                vim.schedule()
                c:close()
            end
        end)

        sftp:exit()
    end
end

deploy_conf = {}

function deploy_conf:azure()
    if not self.conf or not self.conf.path then
        self:reload()
    end
end

function deploy_conf:reload()
    self.conf = Tool.load_project_conf("deploy")
    for k, v in pairs(self.conf.targets) do
        self.curr_target = v
        break
    end
end

function deploy_conf:create()
    Tool.create_project_conf("deploy", template)
end

function deploy_conf:upload_all(args)
    self:azure()
    local files, dirs = Tool.traverse_directory(self.conf.path, nil, self.conf.ignores)

    local my_args = {}
    for i, v in ipairs(args) do
        if v == "-mkdir" then
            my_args.mkdir = true
        end
    end
    process_upload(my_args.mkdir and dirs or {}, files, self.curr_target, self.conf.path)
end

function deploy_conf:upload(args)
    self:azure()
    local my_args = {}
    for i, v in ipairs(args) do
        if v == "-list" then
            my_args.list = true
        elseif v == "-d" then
            my_args.d = args[i + 1]
        elseif v == "-mkdir" then
            my_args.mkdir = true
        end
    end

    if my_args.list then
        -- upload selected file
    elseif my_args.d then
        local files, dirs = Tool.traverse_directory(self.conf.path .. "/" .. my_args.d, my_args.d .. "/", self.conf.ignores)
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
