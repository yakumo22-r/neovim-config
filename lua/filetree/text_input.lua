local util = require("base_func")
local WU = require("window.window_util")
local WG = require("window.window_group")

---@class TextInput:WindowGroup
local ins = {
    ---@type fun(text?:string)
    callback = nil,
    super = WG.class,
}

---@param self TextInput
local function bind_keys(self)
    local buf = self.content.buf
    WU.bind_key(buf, "q", function()
        self:hide()
    end, "n")

    WU.bind_key(buf, "<Esc>", function()
        self:hide()
    end, "n")

    WU.bind_key(buf, "<CR>", function()
        if self.callback then
            self.callback(vim.api.nvim_get_current_line())
            self.callback = nil
        end
        self:hide()
    end, "n")

    WU.bind_key(buf, "<CR>", function()
        if self.callback then
            self.callback(vim.api.nvim_get_current_line())
            self.callback = nil
        end
        vim.cmd("stopinsert") -- 进入插入模式
        self:hide()
    end, "i")
end

function ins:hide()
    if self.callback then
        self.callback()
        self.callback = nil
    end

    self.super.hide(self)
end

---@param tag string
---@param callback function(text?:string)
---@param source_text? string
function ins:init(tag, callback, source_text)
    local title = WU._cell(tag)
    title.indent = math.floor((self.bg.rect.w - title.width) / 2)
    self.cover_lines[1] = { title }
    self.callback = callback
    self:refresh()
    self:show()

    source_text = source_text or ""
    vim.api.nvim_buf_set_lines(self.content.buf, 0, -1, false, { source_text })
    vim.cmd("startinsert") -- 进入插入模式
    vim.cmd("normal! $")
    -- vim.api.nvim_win_set_cursor(0, { 1, #source_text })
end

return function()
    local w = math.min(60, math.floor(vim.o.columns * 0.6))
    local h = 5
    local x = math.floor(vim.o.columns / 2 - w / 2)
    local y = math.floor((vim.o.lines - 2) / 2 - h / 2)

    ---@class TextInput
    local v = util.table_connect(WG.New__WindowGroup(x, y, w, h), ins)
    v.content = v:add_window(1, 1, w, h)

    bind_keys(v)


    local tips = WU._cell(" Press enter to ensure ")
    tips.indent = math.floor((w - tips.width) / 2)
    v.cover_lines = {
        [5] = { tips },
    }

    return v
end
