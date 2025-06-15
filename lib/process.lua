local uv = vim.uv

---@class ProcessManager
local ProcessManager = {}

---@param path string
---@return ProcessManager
function ProcessManager.new(path)
    ---@class ProcessManager
    local ins = {
        ---@type any
        handle = nil,
        ---@type any
        stdin = nil,
        ---@type any
        stdout = nil,
        ---@type any
        stderr = nil,
        path = path,
    }
    for k,f in pairs(ProcessManager) do
        ins[k] = f
    end
    return ins
end

function ProcessManager:start()
    local cmd = self.path
    self.stdout = uv.new_pipe(false)
    self.stderr = uv.new_pipe(false)
    self.stdin = uv.new_pipe(false)

    self.handle = uv.spawn(cmd, {
        stdio = { self.stdin, self.stdout, self.stderr }
    }, function(code, signal)
        vim.notify("Subprocess exited with code " .. code .. " and signal " .. signal)
        self.handle = nil
    end)

    if not self.handle then
        vim.notify("Failed to start subprocess")
        return
    end

    -- 读取 stdout
    self.stdout:read_start(function(err, data)
        local a = {}
        if err then
            vim.schedule(function ()
                vim.notify("Stdout error: " .. err)
            end)
            return
        end
        if data then
            vim.schedule(function ()
                vim.notify("Subprocess output: " .. data)
            end)
        end
    end)

    -- 读取 stderr
    self.stderr:read_start(function(err, data)
        if err then
            vim.notify("Stderr error: " .. err)
            return
        end
        if data then
            vim.notify("Subprocess error: " .. data)
        end
    end)
end

-- 发送任务到子进程
---@param raw string
function ProcessManager:send_raw(raw)
    if not self.handle then
        print("Subprocess not running")
        return
    end

    self.stdin:write(raw, function(err)
        if err then
            print("Write error: " .. err)
        else
            print("Send raw: " .. raw)
        end
    end)
end

function ProcessManager:stop()
    if self.handle then
        self.handle:kill(15) -- SIGTERM
        self.stdout:read_stop()
        self.stderr:read_stop()
        self.stdin:close()
        self.stdout:close()
        self.stderr:close()
        self.handle:close()
    end
end

return ProcessManager
