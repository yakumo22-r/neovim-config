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
        ft_view = New__FT_View(ft_handle)

        wu.bind_key(ft_view.buf, "<esc>", FT.toggle)
    end

    local width = math.floor(vim.o.columns * 0.8)
    local height = vim.o.lines - 4

    if not window_group then
        window_group = WG.New__WindowGroup(1,1,width,height)
        local w = window_group:add_window(1,1,width,4)
        wu.set_only_read(w.wnd)
        window_group:refresh()
    end

    if window_group:is_show() then
        window_group:hide()
    else
        window_group:show()
    end

end

return FT
