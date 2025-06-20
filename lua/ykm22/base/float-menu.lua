--[[
[ ] second menu
[ ] fast key
--]]
local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")
local L = require("ykm22.base.lua-util")

local NsId = vim.api.nvim_create_namespace("ykm22.nvim.FloatMenu")
local StyleHold = "Visual"

---@class ykm22.nvim.FloatMenuELement
---@field label string|ykm22.nvim.StyleCell[]
---@field action? fun(menu:ykm22.nvim.FloatMenu):boolean?
---@field key? string

---@class ykm22.nvim.FloatMenu
local M = {
    ---@type ykm22.nvim.FloatMenuELement[]
    MenuItems = {},
    ---@type table<string, integer?>
    FastKeys = {},
    Buf = -1,
    Win = -1,
    CurrSectionLine = -1,
    Width = 20,
    Height = 12,
    BufWidth = 20,
    NsId = NsId,
    MinusRange = { 0, 0 },
}

---@class ykm22.nvim.FloatMenuClass
local Class = {}

function Class.new()
    ---@class ykm22.nvim.FloatMenu
    local ins = L.clone(M)
    return ins
end

---@param list ykm22.nvim.FloatMenuELement[]
function M:set_list(list)
    self.MenuItems = list
    for k, v in pairs(self.FastKeys) do
        self.FastKeys[k] = 0
    end
end

function M:close()
    if self.Win > 0 then
        vim.api.nvim_win_close(self.Win, true)
    end
end

function M:is_show()
    return self.Win >= 0
end

---@param self ykm22.nvim.FloatMenu
local function refreshStyle(self)
    vim.api.nvim_buf_clear_namespace(self.Buf, -1, 0, -1)
    for l,_ in ipairs(self.lines) do
        local styles = self.lineStyles[l]
        if styles then
            V.set_styles(self.Buf, self.NsId, l, styles)
        end
        if l == self.CurrSectionLine then
            V.set_extmark(self.Buf, self.NsId, StyleHold, { l, 1 })
        end
    end
end

---@param self ykm22.nvim.FloatMenu
local function Enter(self)
    local item = self.MenuItems[self.CurrSectionLine]
    if item and item.action then
        if item.action(self) then
            V.set_extmark(self.Buf, self.NsId, "Done", { self.CurrSectionLine, 1 })
            vim.defer_fn(function()
                self:close()
            end, 200)
        end
    end
end

function M:show()
    self.lastBuf = vim.api.nvim_get_current_buf()
    if self.Buf < 0 then
        self.Buf = vim.api.nvim_create_buf(false, true)
        B.set_buf_nofile(self.Buf)
        B.block_fast_keys(self.Buf)

        B.bind_key(self.Buf, "<Esc>", function()
            vim.api.nvim_win_close(self.Win, true)
        end)
        B.bind_key(self.Buf, "q", function()
            vim.api.nvim_win_close(self.Win, true)
        end)

        B.bind_key(self.Buf, "<CR>", function ()
            Enter(self)
        end)
        B.bind_key(self.Buf, "o", function ()
            Enter(self)
        end)

        vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = self.Buf,
            callback = function()
                local line = vim.api.nvim_win_get_cursor(0)[1]

                local min = 1 + self.MinusRange[1]
                local max = #self.MenuItems - self.MinusRange[2]

                local line2 = math.max(min, math.min(max, line))
                if line2 ~= line then
                    vim.api.nvim_win_set_cursor(self.Win, { line2, 0 })
                end

                if line2 ~= self.CurrSectionLine then
                    self.CurrSectionLine = line2
                    refreshStyle(self)
                end
            end,
        })

        vim.api.nvim_create_autocmd("WinClosed", {
            buffer = self.Buf,
            callback = function()
                self.Win = -1
            end,
        })
        vim.api.nvim_create_autocmd("WinLeave", {
            buffer = self.Buf,
            callback = function()
                if vim.api.nvim_win_is_valid(self.Win) then
                    vim.api.nvim_win_close(self.Win, true)
                    self.Win = -1
                end
            end,
        })
    end

    if self.Win < 0 then
        local opts = {
            relative = "cursor",
            row = 1,
            col = 1,
            width = self.Width,
            height = math.min(#self.MenuItems, self.Height),
            style = "minimal",
            border = "rounded",
        }

        self.Win = vim.api.nvim_open_win(self.Buf, true, opts)
        vim.api.nvim_set_option_value("winfixbuf", true, { win = self.Win })
    end

    ---@type string[]
    self.lines = {}
    ---@type table<integer, ykm22.nvim.BufStyle[]>
    self.lineStyles = {}

    for i, item in ipairs(self.MenuItems) do
        ---@type any
        local line = item.label
        if type(item.label) ~= "string" then
            line, self.lineStyles[i] = V.get_style_line(line)
        end
        table.insert(self.lines, line)
        if item.key then
            self.FastKeys[item.key] = 1
            local ii = i
            B.bind_key(self.Buf, item.key, function()
                self.CurrSectionLine = ii
                Enter(self)
            end, "n")
        end
    end

    for k, v in pairs(self.FastKeys) do
        if v == 0 then
            self.FastKeys[k] = nil
            B.nop_key(self.Buf, k)
        end
    end

    B.set_modifiable(self.Buf, true)
    B.set_lines(self.Buf, 1, -1, self.lines)
    B.set_modifiable(self.Buf, false)

    if self.CurrSectionLine == -1 then
        self.CurrSectionLine = 1
        vim.api.nvim_win_set_cursor(self.Win, { 1, 0 })
    else
        refreshStyle(self)
    end

end

return Class
