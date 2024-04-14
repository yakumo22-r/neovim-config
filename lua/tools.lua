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

function Tool.execute_shell_command(command)
    vim.api.nvim_command("!" .. command)
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
