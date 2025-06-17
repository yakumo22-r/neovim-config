---@type any
local uv = vim.uv

---@class ykm22.SFTP_PIP.Internal
local M = {}

local id = 0

---@alias ykm22.SFTP_PIP.CB_Func fun(id:integer, status:integer, msgs:string[])

---@class ykm22.SFTP_PIP.CB_Funcs
---@field on_response ykm22.SFTP_PIP.CB_Func
---@field on_process_exit fun(msg:string)
---@field sftp_log fun(status:integer, info:string, isErr:boolean?)

---@type ykm22.SFTP_PIP.CB_Funcs
local cb

---@param _cb ykm22.SFTP_PIP.CB_Funcs
function M.register_callbacks(_cb)
    cb = _cb
end

local config_dir = vim.fn.stdpath("config")
local sftp_pip_path
if vim.fn.has("win32") == 1 then
    sftp_pip_path = config_dir .. "/lib/win32/sftp_pip.exe"
    -- sftp_pip_path = "./sftp_pip.exe"
end

---@param callback fun()
function M.start(callback)
    M.stdout = uv.new_pipe(false)
    M.stderr = uv.new_pipe(false)
    M.stdin = uv.new_pipe(false)

    M.handle = uv.spawn(sftp_pip_path, {
        stdio = { M.stdin, M.stdout, M.stderr },
    }, function(code, signal)
        M.stop()
        -- M.handle = nil
        cb.on_process_exit("exec SFTP_PIP exited with code (" .. tostring(code) .. ") and signal -> " .. tostring(signal))
    end)

    if not M.handle then
        callback()
        cb.sftp_log(M.RES_INTERNAL_ERR, "Failed to exec SFTP_PIP")
        return
    end

    M.cache = {}

    -- listen msg
    M.stdout:read_start(function(err, data)
            if err then
                cb.sftp_log(M.RES_NVIM, "SFTP_PIP stdout error: " .. err, true)
            elseif data then
                -- cb.sftp_log(M.RES_NVIM, "SFTP_PIP Subprocess output: " .. data)
                local lines = vim.split(data, "\n", { trimempty = false })
                for _, line in ipairs(lines) do
                    -- vim.notify(" SFTP_PIP Response: '" .. line .. "'\n")
                    if line == "" then
                        if M.cache[1] then
                            M.decode_res(M.cache)
                        end
                        M.cache = {}
                    else
                        table.insert(M.cache, line)
                    end
                end
            end
    end)

    M.stderr:read_start(function(err, data)
        if err then
            cb.sftp_log(M.RES_NVIM, "SFTP_PIP stderr error: " .. err, true)
            return
        end
        if data then
            cb.sftp_log(M.RES_NVIM, "SFTP_PIP Subprocess error: " .. data, true)
        end
    end)
end

M.RES_INTERNAL_ERR = -2
M.RES_ERROR_DONE = -1
M.RES_DONE = 0
M.RES_INFO = 1
M.RES_ERROR = 2
M.RES_HELLO = 99
M.RES_NVIM = 100

M.CBTag = {
    [M.RES_INTERNAL_ERR] = "[INTERNAL_ERR]",
    [M.RES_ERROR_DONE] = "[ERROR_DONE]",
    [M.RES_DONE] = "[SUCCESS_DONE]",
    [M.RES_INFO] = "[INFO]",
    [M.RES_ERROR] = "[ERROR]",
    [M.RES_HELLO] = "[HELLO WORLD]",
    [M.RES_NVIM] = "[NVIM]",
}

---@param msgs string[]
function M.decode_res(msgs)
    local _, b, c = msgs[1]:match("(%d+)%s+(%d+)%s+(%d+)")
    local _id = tonumber(b) or -1
    local status = tonumber(c) or 1
    cb.on_response(_id, status, msgs)
end

---@param cmd integer
---@param sessionId integer
---@param msgs string[]
function M.raw_send(cmd, sessionId, msgs)
    local _id = id
    id = id + 1
    local head = table.concat({ cmd, _id, sessionId }, " ")
    for i, msg in ipairs(msgs) do
        if msg == "" then
            msgs[i] = "#"
        end
    end
    table.insert(msgs, "")
    local msg = head .. "\n" .. table.concat(msgs, "\n") .. "\n"

    M.stdin:write(msg, function(err)
            if err then
                cb.sftp_log(M.RES_NVIM, "SFTP_PIP write error: " .. err, true)
                cb.on_response(_id, M.RES_INTERNAL_ERR, { "", "SFTP_PIP write error: " .. err })
                M.stop()
            else
                -- cb.sftp_log(M.RES_NVIM, "SFTP_PIP send raw: \n" .. msg)
            end
    end)

    return _id
end

function M.running()
    return M.handle ~= nil
end

function M.stop()
    if M.handle then
        id = 0
        M.handle:kill(15) -- SIGTERM
        M.stdout:read_stop()
        M.stderr:read_stop()
        M.stdin:close()
        M.stdout:close()
        M.stderr:close()
        M.handle:close()
    end
end

return M
