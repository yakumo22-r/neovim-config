vim.cmd("source " .. vim.fn.stdpath("config") .. "/base.vim")
vim.g.mapleader = " "

require("base_func")
require("tools")
require("user")
require("settings")
require("comment")
require("compile_conf")
require("deploy_conf")
require("formatcmd")

_G.ykm22_cols = require("ykm22_colors")

require("ykm22_theme")

require("xmake_conf")

require("lazy-setup")

local script_dir = vim.fn.expand("<sfile>:p:h")
package.path = package.path .. ";" .. script_dir .. "/" .. "lib/?.lua"
require("c_api")
