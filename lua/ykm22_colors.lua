local dir = vim.loop.os_homedir() .. "/.config/wezterm/colors"
local filepath = dir .. "/ykm22_wez_colors.lua"
local file = io.open(filepath, "r")

if file then
    file:close()
else
    if not vim.loop.fs_stat(dir) then
        vim.fn.system('mkdir -p "' .. dir .. '"')
    end
    vim.fn.system(
        "wget -O "
            .. filepath
            .. " https://raw.githubusercontent.com/yakumo22-r/wezterm-config/master/colors/ykm22_wez_colors.lua"
    )
end


local originalPath = package.path
package.path = filepath .. ";" .. package.path

---@type COLORS
local result = require("ykm22_wez_colors")
package.path = originalPath


---@class COLORS
---@field fuck string
---@field dark0_hard string
---@field dark0 string
---@field dark0_soft string
---@field dark1 string
---@field dark2 string
---@field dark3 string
---@field dark4 string
---@field light0_hard string
---@field light0 string
---@field light0_soft string
---@field light1 string
---@field light2 string
---@field light3 string
---@field light4 string
---@field bright_red string
---@field bright_green string
---@field bright_yellow string
---@field bright_blue string
---@field bright_purple string
---@field bright_aqua string
---@field bright_orange string
---@field neutral_red string
---@field neutral_green string
---@field neutral_yellow string
---@field neutral_blue string
---@field neutral_purple string
---@field neutral_aqua string
---@field neutral_orange string
---@field faded_red string
---@field faded_green string
---@field faded_yellow string
---@field faded_blue string
---@field faded_purple string
---@field faded_aqua string
---@field faded_orange string
---@field dark_red_hard string
---@field dark_red string
---@field dark_red_soft string
---@field light_red_hard string
---@field light_red string
---@field light_red_soft string
---@field dark_green_hard string
---@field dark_green string
---@field dark_green_soft string
---@field light_green_hard string
---@field light_green string
---@field light_green_soft string
---@field dark_aqua_hard string
---@field dark_aqua string
---@field dark_aqua_soft string
---@field light_aqua_hard string
---@field light_aqua string
---@field light_aqua_soft string
---@field gray string
---@field warm_light string
---@field rosewater string
---@field surface2 string
---@field surface1 string
---@field surface0 string
---@field flamingo string
---@field peach string
---@field subtext string
---@field overlay string
---@field term table<integer,string>

return result
