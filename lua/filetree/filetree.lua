-- filetree window
local wu = require("window.window_util")
local util = require("base_func")

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
        print("hide")
        ft_view:hide()
        
    else
        print("show")
        ft_view:show()
        -- local Window = require("window.window")
        -- local wu = require("window.window_util")
    end

-- local uv = vim.loop
-- local handle = uv.new_fs_event()

-- local in_time = false
-- local _events = {}

-- local function watch_folder(path)
--     -- 创建 fs_event 句柄
--     local handle = uv.new_fs_event()
--     if not handle then
--         print("Failed to create fs_event handle")
--         return
--     end

--     -- 回调函数，处理文件系统事件
--     local function on_change(err, filename, events)
--         if err then
--             print("Error: " .. err)
--             return
--         end

--         if events.rename then
--             table.insert(_events, filename)
--             if not in_time then
--                 in_time = true
--                 vim.defer_fn(function ()
--                     in_time = false

--                     local es = _events
--                     _events = {}

--                     print(table.concat(es, ' '))

--                 end, 500)
--             end
--         end
--     end

--     -- 启动监控
--     local success = uv.fs_event_start(handle, path, { recursive = false }, on_change)
--     if not success then
--         print("Failed to start monitoring: " .. path)
--         uv.close(handle)
--         return
--     end

--     print("Started monitoring: " .. path)
--     return handle
-- end

-- watch_folder(vim.fn.getcwd())

end

return FT
