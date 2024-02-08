local filepath = vim.loop.os_homedir().."/.config".."/vim-user.lua"
local file = io.open(filepath, "r")

if file then
	file:close()
else
	local default_user_table=
[[
return
{
	{import = "plugins"},
	{import = "plugins.lsp"},
}
]]
	file = io.open(filepath, "w")
	if(file)then
		file:write(default_user_table)
		file:close()
	else
		print('cannot open file for writting: '..filepath)
	end
end

local originalPath = package.path
package.path = filepath..";" .. package.path
User = require("nvim-user")
package.path = originalPath

require('settings')
require('keymaps')
require('ykm22_theme')
require("lazy-setup")
