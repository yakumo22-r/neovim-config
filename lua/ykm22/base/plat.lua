---@class ykm22.nvim.plat
local M = {}

local _is_mac_m1 = nil
function M.is_mac_m1()
    if _is_mac_m1 == nil then
        local arch = vim.fn.has("mac") == 1 and vim.fn.system("uname -m"):gsub("%s+", "")
        print(arch)
        _is_mac_m1 = arch == "arm64" or arch == "aarch64"
    end

    return _is_mac_m1
end

local _is_mac_x86 = nil
function M.is_mac_x86()
    if _is_mac_x86 == nil then
        local arch = vim.fn.has("mac") == 1 and vim.fn.system("uname -m"):gsub("%s+", "")
        _is_mac_x86 = arch == "x86_64"
    end
    return _is_mac_x86
end

local _is_win32 = nil

---@param exec string
function M.get_local_exec(exec)
    local config_dir = vim.fn.stdpath("config")
    local dir = "linux"
    local pattern = "";
    if vim.fn.has("win32") == 1 then
        dir = "win32"
        pattern = ".exe"
    elseif M.is_mac_m1() then
        dir = "mac-m1"
    elseif M.is_mac_x86() then
        dir = "mac-x86"
    end
    return string.format("%s/lib/%s/%s%s",config_dir,dir,exec,pattern)
end

return M
