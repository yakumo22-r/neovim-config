---@type any
local uv = vim.uv

local M = {}

---@param exec string
---@param args string[]
---@param callback fun(s:string)
---@param cwd string?
function M.run(exec, args, callback, cwd)
    local stdout = uv.new_pipe(false)

    local handle 
    local datas = ""
    handle = uv.spawn(exec, {
        args = args,
        cwd = cwd,
        stdio = { nil, stdout, nil },
    }, function(code, signal)
        if code ~= 0 then
            vim.schedule(function()
                    vim.notify("Command failed with code: " .. code .. " and signal: " .. tostring(signal), vim.log.levels.ERROR)
            end)
        end
        handle:close()
        stdout:close()
    end)

    stdout:read_start(function(err, data)
        vim.schedule(function()
            if err then
                vim.notify("Pip stdout error: " .. err, vim.log.levels.ERROR)
            else
                if not data then
                    callback(datas)
                else
                    datas = datas .. data
                end
            end
        end)
    end)
end

return M
