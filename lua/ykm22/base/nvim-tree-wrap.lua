---@class ykm22.nvim.NvimTreeWrap
local M = {}

local Enable = false
local Api = nil

local OpenFile = nil

function M.on_nvim_tree_loaded() 
    Api = require("nvim-tree.api")
    OpenFile = require("nvim-tree.actions.node.open-file")
    Enable = true 
end
function M.useable() return Enable end

function M.edit(path)
    OpenFile.fn("edit", path)
end

return M
