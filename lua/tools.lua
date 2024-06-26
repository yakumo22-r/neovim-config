Tool = {}

local projectConfDir = ".ykm.nvim.proj"
function Tool.load_project_conf(name)
    local current_dir = Tool.get_current_directory()
    local project_config_file = string.format("%s/%s/.%s.lua", current_dir, projectConfDir, name)
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
        project_config_file = string.format("%s/%s/.%s.lua", current_dir, projectConfDir, name)
    end
    print(string.format("no .%s.lua file found please run create"), name)
end

function Tool.get_project_dir()
    local current_dir = Tool.get_current_directory()
    local dir = string.format("%s/%s", current_dir, projectConfDir)
    while current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
        if Tool.dir_exsists(dir) then
            return dir
        end
        current_dir = vim.fn.fnamemodify(current_dir, ":h")
        dir = string.format("%s/%s", current_dir, projectConfDir)
    end
    return Tool.get_current_directory()
end

function Tool.get_parent_dir(dir)
    return vim.fn.fnamemodify(dir, ":h")
end

function Tool.create_directory(...)
    local pathes = { ... }
    local path
    if vim.fn.has("win32") == 1 then
        for i, v in ipairs(pathes) do
            path = path and string.format("%s\\%s", path, v) or v
        end
        os.execute('mkdir "' .. path .. '"')
    else
        for i, v in ipairs(pathes) do
            path = path and string.format("%s/%s", path, v) or v
        end
        os.execute('mkdir -p "' .. path .. '"')
    end
    return path
end

function Tool.create_project_conf(name, content)
    Tool.create_directory(Tool.get_current_directory(), projectConfDir)
    local project_config_file = string.format("%s/%s/.%s.lua", Tool.get_current_directory(), projectConfDir, name)
    file = io.open(project_config_file, "w")
    if file then
        if content then
            file:write(content)
        end
        file:close()
    else
        print("cannot open file for writting: " .. project_config_file)
    end
end

function Tool.dir_exsists(path)
    local stat = vim.loop.fs_stat(path)
    print(stat and stat.type or false)
    return stat and stat.type or false
end
function Tool.file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- Function to load and execute Lua code from a file
function Tool.load_file_and_execute(file_path)
    if Tool.file_exists(file_path) then
        return loadfile(file_path)
    end
end

function Tool.get_current_directory()
    return vim.fn.expand("%:p:h")
end

function Tool.execute_shell_command(command, method)
    if method == "toggle" then
        TermExec(command, "execute", 1)
        --vim.api.nvim_command("TermExec cmd=\'" .. command .. "\'")
    elseif method == "system" then
        local os_type = vim.loop.os_uname().sysname
        if os_type == "Windows" then
            os.execute("start " .. command)
        else
            TermExec(command, "execute", 1)
        end
    else
        vim.api.nvim_command("!" .. command)
    end
end

function Tool.get_value(c, self, ...)
    if type(c) == "function" then
        if not self then
            return c(...)
        else
            return c(self, ...)
        end
    end
    return c
end

function Tool.start_matchs(str, patterns)
    if not patterns then
        return false
    end
    for i, v in ipairs(patterns) do
        if #str >= #v and str:sub(1, #v) == v then
            return true
        end
    end
    return false
end

function Tool.traverse_directory(path, prefix, ignores)
    local files = vim.fn.readdir(path)

    local result_files = {}
    local result_dirs = {}

    for _, file in ipairs(files) do
        if file ~= "." and file ~= ".." then
            local filepath = path .. "/" .. file
            local filestat = vim.loop.fs_stat(filepath)
            if filestat and filestat.type == "directory" then
                local rv = prefix and (prefix .. file .. "/") or (file .. "/")
                if not Tool.start_matchs(rv, ignores) then
                    local sub_files, sub_dirs = Tool.traverse_directory(filepath, rv, ignores)
                    table.insert(result_dirs, prefix and (prefix .. file) or file)

                    for i, v in ipairs(sub_files) do
                        table.insert(result_files, v)
                    end

                    for i, v in ipairs(sub_dirs) do
                        table.insert(result_dirs, v)
                    end
                end
            else
                local rv = prefix and (prefix .. file) or file
                if not Tool.start_matchs(rv, ignores) then
                    table.insert(result_files, rv)
                end
            end
        end
    end

    return result_files, result_dirs
end

function Tool.get_buffer_path(base_path)
    -- 获取当前 buffer 的文件名
    local buffer_name = vim.api.nvim_buf_get_name(0)
    if base_path then
        local str = buffer_name:gsub(base_path, ""):gsub("\\", "/")
        if str:sub(1, 1) == "/" then
            return str:sub(2)
        else
            return str
        end
    else
        return buffer_name:gsub("\\", "/")
    end
end

function Tool.parent_of_relative(path)
    local last_slash_index = path:find("/[^/]*$")
    if last_slash_index then
        return path:sub(1, last_slash_index - 1)
    else
        return ""
    end
end
