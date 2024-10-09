-- vimrc ./base.vim
vim.cmd("source " .. vim.fn.stdpath("config") .. "/base.vim") 
vim.g.mapleader = " "


-- tool
require("base_func")
require("tools")
require("comment")
require("formatcmd")
require("compile_conf") -- in develop
require("deploy_conf") -- in develop
require("xmake_conf") -- in develop

-- custom theme
_G.ykm22_cols = require("ykm22_colors")
require("ykm22_theme")

-- plugins & settings
require("user")
require("settings")
require("lazy-setup")


-- c-api lib
local script_dir = vim.fn.expand("<sfile>:p:h")
package.path = package.path .. ";" .. script_dir .. "/" .. "lib/?.lua"
require("c_api")
