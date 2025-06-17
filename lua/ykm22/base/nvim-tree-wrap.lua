---@class ykm22.nvim.NvimTreeWrap
local M = {}

local Enable = false
local Api = nil

function M.on_nvim_tree_loaded() 
    Api = require("nvim-tree.api")
    Action = require("nvim-tree.actions")
    Enable = true 
end
function M.useable() return Enable end

function M.edit(path)
    Action.node.open_file.fn("edit", path)
end

return M
