-- filetree window
local wu = require("window.window_util")

local FH = require("filetree.filetree_handle")
local New__FT_View = require("filetree.filetree_view")

local FT = {}

---@type FT_Handler
local ft_handle = nil

---@type FT_View
local ft_view = nil

---@type WindowGroup
local window_group = nil

local function get_wh()
    local width = math.floor(vim.o.columns * 0.8)
    width = math.min(width, 60)
    local height = vim.o.lines - 2
    return { w = width, h = height }
end

function FT.toggle()
    if ft_handle == nil then
        local wh = get_wh()
        ft_handle = FH.New__FT_Handler(vim.fn.getcwd())
        ft_view = New__FT_View(ft_handle, wh.w, wh.h)

        wu.bind_key(ft_view.bg.buf, "<esc>", FT.toggle)

        vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
                ft_view:on_vim_resize(get_wh())
            end,
        })
    end

    if ft_view:is_show() then
        ft_view:hide()
    else
        ft_view:show()
    end
end

return FT
