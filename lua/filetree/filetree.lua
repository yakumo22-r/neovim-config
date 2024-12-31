-- filetree window
local api = vim.api
local uv = vim.loop
local wu = require("window.window_util")

local New__FT_Handler= require("filetree.filetree_handle")
local New__FT_View = require("filetree.filetree_view")

local WG = require "window.window_group"
local FT = {}

---@type FT_Handler
local ft_handle = nil

---@type FT_View
local ft_view = nil

---@type WindowGroup
local window_group = nil

function FT.toggle()
    -- buffer

    if ft_handle == nil then

        ft_handle = New__FT_Handler(vim.fn.getcwd())

        local width = math.floor(vim.o.columns * 0.8)
        width = math.min(width, 60)
        local height = vim.o.lines-1

        ft_view = New__FT_View(ft_handle,width,height)

        wu.bind_key(ft_view.bg.buf, "<esc>", FT.toggle)
    end


    if ft_view:is_show() then
        ft_view:hide()
    else
        ft_view:show()
    end

end

return FT
