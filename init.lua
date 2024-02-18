local dir = vim.loop.os_homedir() .. "/.config"
local filepath = dir .. "/vim-user.lua"
local file = io.open(filepath, "r")

if file then
    file:close()
else
    if not vim.loop.fs_stat(dir) then
        vim.fn.system('mkdir -p "' .. dir .. '"')
    end
    local default_user_table = [[
local default_formatrc_path = vim.fn.stdpath('config')..'/formatrc/'
-- stylua: ignore
return {
    plugins = {
        { import = "plugins" },
        import = "plugins.lsp" },
    },

    formatrc = {
        prettier = default_formatrc_path .. ".prettierrc.json",
    },
}
]]
    file = io.open(filepath, "w")
    if file then
        file:write(default_user_table)
        file:close()
    else
        print("cannot open file for writting: " .. filepath)
    end
end

local originalPath = package.path
package.path = filepath .. ";" .. package.path
User = require("nvim-user")
package.path = originalPath

require("settings")
require("keymaps")
require("ykm22_theme")
require("lazy-setup")
