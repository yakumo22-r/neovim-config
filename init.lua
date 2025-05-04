YKM22 = {}

-- vimrc ./base.vim
vim.cmd("source " .. vim.fn.stdpath("config") .. "/base.vim")

-- vimrc ./base2.vim
vim.cmd("source " .. vim.fn.stdpath("config") .. "/base2.vim")
vim.g.mapleader = " "

vim.opt.clipboard = ""

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

-- ensure env path
local function ensure_env_path(path)
    path = ":"..path
    if not string.find(vim.env.PATH, path, 1, true) then
        vim.env.PATH = vim.env.PATH .. path
    end
end

ensure_env_path("/usr/local/bin")
if vim.fn.has("macunix") == 1 then
    ensure_env_path("/opt/homebrew/bin")
end

local PF = require("project.project_file")
-- if dir .nvim under cwd exists, set undodir as .nvim/undo/. else do nothing
PF:check_use_undo_dir()

-- c-api lib
local script_dir = vim.fn.expand("<sfile>:p:h")
package.path = package.path .. ";" .. script_dir .. "/" .. "lib/?.lua"
require("c_api")
