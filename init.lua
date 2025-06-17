YKM22 = {}


--  readme.md

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
require("ykm22.theme")
require("ykm22.terminal") -- project management
require("ykm22.terminal_view") -- project management
local GitChangeView = require("ykm22.git-changes-view")
local ProjectFile = require("ykm22.base.project-file")
local Sftp = require("ykm22.sftp")

GitChangeView.setup(ProjectFile.get_file)
Sftp.setup(ProjectFile.get_file)

ProjectFile.setup({
    function(root)
        vim.opt.undodir = root .. "/.undo/"
    end,
    function (root)
        root = vim.fn.fnamemodify(root,":h")
        Sftp.init(root)
    end

})
GitChangeView.init(vim.fn.fnamemodify(ProjectFile.get_root(),":h"))


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

-- c-api lib
local script_dir = vim.fn.expand("<sfile>:p:h")
package.path = package.path .. ";" .. script_dir .. "/" .. "lib/?.lua"
require("c_api")


