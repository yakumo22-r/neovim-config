
---@class ykm22.nvim.Sftp
local M = {}

-- TAG: Config

---@type ykm22.nvim.SftpConf[]
local confs = nil
---@type table<string,ykm22.nvim.SftpConf>
local confMaps = {}
---@type ykm22.nvim.SftpConf
local curr = nil

---@type string
local _root = nil

local scriptPath = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h")

---@type fun(file:string,_, _):string?,string
local _readCfg = nil

---@param content string?
local function parseCfg(content)
    content = content or _readCfg("sftp_conf.lua")

    if not content then
        -- vim.notify("Failed to read sftp_conf.lua. Please run :InitSftpConf", vim.log.levels.ERROR)
        return
    end
    local ok, err = load(content)
    if ok then
        local v = ok()
        confs = v.confs
        confMaps = {}
        for _, conf in ipairs(confs) do
            confMaps[conf.name] = conf
        end

        curr = confMaps[v.default] or v.confs[1]
        M.register_hosts(v.hosts)
    end
end

function M.get_confs()
    return confs
end

function M.get_curr_conf()
    return curr
end

function M.get_root()
    return _root
end

function M.get_conf_by_name(name)
    return name and confMaps[name] or nil
end

-- TAG: Response
local SFTP_PIP = require("lib.sftp_pip")
local ClientReady = false
local Starting = false
---@type fun()[]
local WaitReadyCmds = {}

---@param cmd fun()
function M.wait_client_ready(cmd)
    if not ClientReady then
        if not Starting then
            Starting = true
            SFTP_PIP.start(function()
                Starting = false
            end)
        end
        table.insert(WaitReadyCmds, cmd)
        return true
    end
end

---@class ykm22.nvim.SftpCallback
---@field cmd integer
---@field callback? fun(done:boolean, err?:boolean, msgs?:string[])
---@type table<integer, ykm22.nvim.SftpCallback>
local Callbacks = {}

local CMD_NEW_SESSION = 0
local CMD_UPLOADS = 1
local CMD_DOWNLOADS = 2
local CMD_CLOSE_SESSION = 3
local CMD_STATUS_SESSION = 4

---@param id integer
---@param status integer
---@param msgs string[]
local function on_response(id, status, msgs) 
    if status == SFTP_PIP.RES_HELLO then
        ClientReady = true
        Starting = false
        for _, callback in ipairs(WaitReadyCmds) do
            callback()
        end
        M.log(SFTP_PIP.RES_HELLO, "SFTP_PIP: Client is ready")
        WaitReadyCmds = {}
        return
    end

    local wait = Callbacks[id]
    if not wait then
        M.log(SFTP_PIP.RES_NVIM, "SFTP_PIP: No wait found for id: " .. tostring(id))
        return
    end

    local info = msgs[2] or ""
    for i=3,#msgs do
        info = info .. "    \n" .. msgs[i]
    end
    M.log(status, info)
    local done = status < 1
    local err = status == 2 or status < 0

    if wait.callback then
        wait.callback(done, err, msgs)
    end

    if done then
        Callbacks[id] = nil
    end
end

---@param msg string
local function on_process_exit(msg)
    Callbacks = {}
    SessionMap = {}
    ClientReady = false
    Starting = false
    M.log(SFTP_PIP.RES_NVIM, msg)
end



-- TAG: Request
---@class ykm22.nvim.SftpSession
---@field sessionId? integer
---@field user? string
---@field port? integer
---@field password? string
---@field queue function[]
---@field logging? boolean

---@type table<string,ykm22.nvim.SftpSession>
local SessionMap = {}

function M.log(status, info, err)
    local tag = SFTP_PIP.CBTag[status] or "[UNKNOWN]"
    local time = os.date("%H:%M:%S")
    vim.schedule(function()
        if not err then
            print(string.format("%s %s %s", time, tag, info))
        else
            vim.notify(string.format("%s %s %s", time, tag, info), vim.log.levels.ERROR)
        end
    end)
end

---@param hosts ykm22.nvim.SftpHost[]
function M.register_hosts(hosts)
    for _, host in ipairs(hosts) do
        local s = SessionMap[host.domain]
        s = s or {}
        s.user = host.username
        s.port = host.port
        s.password = host.password
        s.queue = {}
    end
end

---@param hostname string
---@param cmd fun()
function M.wait_login(hostname, cmd)
    local info = SessionMap[hostname]
    if not info then
        M.log(SFTP_PIP.RES_NVIM, "SFTP_PIP: No session found for hostname: " .. tostring(hostname), true)
        return true
    end

    if not info.logging then
        table.insert(M.queue, cmd)
        return true
    elseif not info.sessionId then
        M.login(hostname)
        table.insert(M.queue, cmd)
        return true
    end
end

---@param hostname string
function M.login(hostname)
    local info = SessionMap[hostname]
    local user = info.user or "#"
    local port = info.port or "#"
    local password = info.password or "#"
    info.logging = true

    if M.wait_client_ready(function()
        M.login(hostname)
    end) then
        return
    end

    info.sessionId = -1
    local reqId = SFTP_PIP.raw_send(CMD_NEW_SESSION, 0, {
        hostname,
        user,
        tostring(port),
        password or "#",
    })

    Callbacks[reqId] = {
        cmd = CMD_NEW_SESSION,
        callback = function(done, err, msgs)
            if not err and done then
                info.sessionId = tonumber(msgs[2])
                info.logging = false
                for _,cmd in ipairs(info.queue) do
                    cmd()
                end
                info.queue = {}
            end
        end,
    }
end

---@param hostname string
---@param localRoot string
---@param remoteRoot string
---@param files string[]
function M.upload_files(hostname, localRoot, remoteRoot, files)
    local info = SessionMap[hostname]

    if M.wait_login(hostname, function()
        M.upload_files(hostname, localRoot, remoteRoot, files)
    end) then
        return
    end

    local reqId = SFTP_PIP.raw_send(CMD_UPLOADS, info.sessionId, {
        localRoot,
        remoteRoot,
        table.concat(files, "\n"),
    })

    Callbacks[reqId] = { cmd = CMD_UPLOADS }
end

---@param hostname string
---@param localRoot string
---@param remoteRoot string
---@param files string[]
function M.dowload_files(hostname, localRoot, remoteRoot, files)
    local info = SessionMap[hostname]

    if M.wait_login(hostname, function()
        M.dowload_files(hostname, localRoot, remoteRoot, files)
    end) then
        return
    end


    local reqId = SFTP_PIP.raw_send(CMD_DOWNLOADS, info.sessionId, {
        localRoot,
        remoteRoot,
        table.concat(files, "\n"),
    })

    Callbacks[reqId] = { cmd = CMD_DOWNLOADS }
end

function M.check_not_ready()
    if confs == nil then
        vim.notify("SFTP: No configuration found. Please run :SftpInitConf", vim.log.levels.ERROR)
        return true
    end
end

function M.cmd_init_sftp_conf()
    local content
    content = _readCfg("sftp_conf.lua", nil, scriptPath .. "/conf_temp/sftp_conf.lua")
    if not content then
        vim.notify("Failed to init sftp_conf", vim.log.levels.ERROR)
    end
    parseCfg(content)
end

function M.cmd_list_conf()
    if M.check_not_ready() then return end
    print("SFTP list")
    for _, conf in ipairs(confs) do
        print(string.format("%s - host: %s, remote: %s", conf.name, conf.host.domain, conf.remoteRoot))
    end
end

function M.cmd_switch_conf(opts, name)
    if M.check_not_ready() then return end
    local v = opts and tostring(opts.args) or name
    if confMaps[v] then
        curr = confMaps[v]
    else
        vim.notify("SFTP: No configuration found for " .. v, vim.log.levels.ERROR)
        return
    end
end

function M.cmd_upload(conf,files)
    conf = conf or curr
    if files then
        M.upload_files( --
            conf.host.domain,
            M.get_root(),
            conf.remoteRoot,
            files
        )
    else
        vim.notify("No valid file to upload", vim.log.levels.ERROR)
    end
end

function M.cmd_sync(conf,files)
    conf = conf or curr
    if files then
        M.dowload_files( --
            conf.host.domain,
            M.get_root(),
            conf.remoteRoot,
            files
        )
    else
        vim.notify("No valid file to sync", vim.log.levels.ERROR)
    end
end

---@param readCfg fun(file:string,_, _):string?,string
---@param root string
function M.setup(readCfg, root)
    _readCfg = readCfg
    parseCfg()

    _root = vim.fn.fnamemodify(root,":h")

    M.view = require("ykm22.sftp_view")
    M.view.setup(M)

    SFTP_PIP.register_callbacks({
        on_response = on_response,
        on_process_exit = on_process_exit,
        sftp_log = M.log,
    })

    vim.api.nvim_create_user_command("SftpInitConf", M.cmd_init_sftp_conf, {})
    vim.api.nvim_create_user_command("SftpLs", M.cmd_list_conf, {})
    vim.api.nvim_create_user_command("SftpSwitch", M.cmd_switch_conf, {
        nargs = 1,
        complete = function(_, line)
            return vim.tbl_keys(confMaps)
        end,
    })
end

return M
