local dir = vim.loop.os_homedir().."/.config/wezterm/colors"
local filepath = dir.."/ykm22_wez_colors.lua"
local file = io.open(filepath, "r")

if file then
	file:close()
else
	if not vim.loop.fs_stat(dir) then
		vim.fn.system('mkdir -p "'..dir..'"')
	end
	vim.fn.system('wget -O '..filepath..' https://raw.githubusercontent.com/yakumo22-r/wezterm-config/master/colors/ykm22_wez_colors.lua')
end

local originalPath = package.path
package.path = filepath..";" .. package.path
local result = require("ykm22_wez_colors")
package.path = originalPath
return result
--
-- -- version: 0.0.5
-- -- author: yakumo22
-- local colors = {
-- 	dark0_hard = "#1d2021",
-- 	dark0 = "#282828",
-- 	dark0_soft = "#32302f",
-- 	dark1 = "#3c3836",
-- 	dark2 = "#504945",
-- 	dark3 = "#665c54",
-- 	dark4 = "#7c6f64",
-- 	light0_hard = "#f9f5d7",
-- 	light0 = "#fbf1c7",
-- 	light0_soft = "#f2e5bc",
-- 	light1 = "#ebd6c0",
-- 	light2 = "#d5c4a1",
-- 	light3 = "#bdae93",
-- 	light4 = "#a89984",
-- 	bright_red = "#f85a50",
-- 	bright_green = "#80b270",
-- 	bright_yellow = "#fabd2f",
-- 	bright_blue = "#73b5e8",
-- 	bright_purple = "#d3869b",
-- 	bright_aqua = "#8ec07c",
-- 	bright_orange = "#fe8019",
-- 	neutral_red = "#cc241d",
-- 	neutral_green = "#98971a",
-- 	neutral_yellow = "#d79921",
-- 	neutral_blue = "#458588",
-- 	neutral_purple = "#b16286",
-- 	neutral_aqua = "#689d6a",
-- 	neutral_orange = "#d65d0e",
-- 	faded_red = "#9d0006",
-- 	faded_green = "#79740e",
-- 	faded_yellow = "#b57614",
-- 	faded_blue = "#076678",
-- 	faded_purple = "#8f3f71",
-- 	faded_aqua = "#427b58",
-- 	faded_orange = "#af3a03",
-- 	dark_red_hard = "#792329",
-- 	dark_red = "#722529",
-- 	dark_red_soft = "#7b2c2f",
-- 	light_red_hard = "#fc9690",
-- 	light_red = "#fc9487",
-- 	light_red_soft = "#f78b7f",
-- 	dark_green_hard = "#5a633a",
-- 	dark_green = "#62693e",
-- 	dark_green_soft = "#686d43",
-- 	light_green_hard = "#d3d6a5",
-- 	light_green = "#d5d39b",
-- 	light_green_soft = "#cecb94",
-- 	dark_aqua_hard = "#3e4934",
-- 	dark_aqua = "#49503b",
-- 	dark_aqua_soft = "#525742",
-- 	light_aqua_hard = "#e6e9c1",
-- 	light_aqua = "#e8e5b5",
-- 	light_aqua_soft = "#e1dbac",
-- 	gray = "#928374",
-- 	warm_light = "#f5c0b2",
-- }
--
-- colors.term = {
-- 	colors.bg0,
-- 	colors.neutral_red,
-- 	colors.neutral_green,
-- 	colors.neutral_yellow,
-- 	colors.neutral_blue,
-- 	colors.neutral_purple,
-- 	colors.neutral_aqua,
-- 	colors.fg4,
-- 	colors.gray,
-- 	colors.red,
-- 	colors.green,
-- 	colors.yellow,
-- 	colors.blue,
-- 	colors.purple,
-- 	colors.aqua,
-- 	colors.fg1,
-- }
--
-- return colors
