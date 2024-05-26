require("tools")
require("user")
require("settings")
require("keymaps")
require("comment")
require("compile_conf")
require("deploy_conf")
require("formatcmd")
require("ykm22_theme")

require("xmake_conf")

require("lazy-setup")

local script_dir = vim.fn.expand("<sfile>:p:h")
package.path = package.path .. ";"..script_dir.."/".."lib/?.lua"
require("c_api")
