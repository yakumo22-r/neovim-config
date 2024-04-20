Tool = {}

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
