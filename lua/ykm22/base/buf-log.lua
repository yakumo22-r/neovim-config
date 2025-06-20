local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")
local L = require("ykm22.base.lua-util")

-- TODO: 
-- Highlight [ ]

---@class ykm22.nvim.BufLogClass
local Class = {}

Class.StyleRed = "LogRed"
Class.StyleGreen = "LogGreen"
Class.StyleBlue = "LogBlue"
Class.StyleYellow = "LogYellow"

---@class ykm22.nvim.BufLog
local M = {
    Lines = {},

    ---@type string[]
    nLines = {},

    ---@type table<integer,string>
    Styles = {},

    ---@type table<integer,string>
    nStyles = {},

    maxLines = 800,
    reduceNum = 400,
}

function M:is_show()
    return self.Buf and self.Win
end

---@param self ykm22.nvim.BufLog
local function flushLines(self)
    local baseLNum = #self.Lines
    local nLNum = #self.nLines
    B.set_modifiable(self.Buf, true)
    if baseLNum + nLNum > self.maxLines then
        local reduceNum = math.min(self.reduceNum, baseLNum)
        B.set_lines(self.Buf, 1, reduceNum, {})
        local lines = {}
        local nStyle = {}
        for i = reduceNum + 1, baseLNum do
            table.insert(lines, self.Lines[i])
            if self.Styles[i] then
                nStyle[i - reduceNum] = self.Styles[i]
            end
        end
        self.Lines = lines
        self.Styles = nStyle
        vim.api.nvim_buf_clear_namespace(self.Buf, self.NsId, 0, -1)
        for i, v in pairs(self.Styles) do
            V.set_extmark(self.Buf, self.NsId, v, { i, 1})
        end
    end

    B.set_lines(self.Buf, #self.Lines+1, -1, self.nLines)
    B.set_modifiable(self.Buf, false)
    baseLNum = #self.Lines
    for i = 1, #self.nLines do
        table.insert(self.Lines, self.nLines[i])
        if self.nStyles[i] then
            local l = baseLNum + i
            local style = self.nStyles[i]
            self.Styles[l] = style
            V.set_extmark(self.Buf, self.NsId, style, { l, 1})
        end
    end

    if self.Win then
        vim.api.nvim_win_set_cursor(self.Win, { #self.Lines, 0 })
    end
    self.nLines = {}
    self.nStyles = {}
end

function M:show()
    if not self.Buf then
        self.Buf = vim.api.nvim_create_buf(false, true)
        B.set_buf_nofile(self.Buf)
        B.block_fast_keys(self.Buf)


        B.bind_key(self.Buf, "<Esc>", function()
            vim.api.nvim_win_close(self.Win, true)
        end)
        B.bind_key(self.Buf, "q", function()
            vim.api.nvim_win_close(self.Win, true)
        end)

        -- B.set_modifiable(self.Buf, true)
        -- B.set_lines(self.Buf, 1, -1, self.Lines)
        -- B.set_modifiable(self.Buf, false)
        flushLines(self)

        B.autocmds(self.Buf, {"WinClosed", "WinNew"}, function(ev)
            if ev.event == "WinNew" then
            else
                self.Win = nil
            end
        end)

        B.autocmds(self.Buf,{ "BufHidden", "BufDelete" }, function (ev)
            self.Win = nil
            if ev == "BufDelete" then
                B.clear_buf_autocmds(self.Buf)
                self.Buf = nil
            end
        end)
    end


    vim.api.nvim_command("botright split")
    self.Win = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_height(self.Win, math.floor(vim.o.lines*0.4))
    -- vim.api.nvim_win_set_width(self.Win, math.floor(vim.o.columns*0.3))
    vim.api.nvim_win_set_hl_ns(self.Win, self.NsId)
    vim.api.nvim_win_set_buf(self.Win, self.Buf)
    vim.api.nvim_set_option_value("winfixbuf", true, { win = self.Win })
end

function M:hide()
    if self.Win then
        vim.api.nvim_win_close(self.Win, false)
    end
end

function M:append(msgs, col)
    -- if #self.Lines > 400 then
    --     self:clear(100)
    -- end

    local lines = vim.tbl_map(vim.trim, vim.split(msgs, "\n"))

    local lineNum = #self.nLines
    for i,line in ipairs(lines) do
        table.insert(self.nLines, line)
        if col then
            self.nStyles[lineNum + i] = col
        end
    end

    if self.Buf then
        flushLines(self)
    end
end

-- function M:clear(lastNum)
--     if self.Buf then
--         B.set_modifiable(self.Buf, true)
--         B.set_lines(self.Buf, 1, lastNum, {})
--         B.set_modifiable(self.Buf, false)
--     end
--     local nLines = {}
--     for i = lastNum + 1, #self.Lines do
--         table.insert(nLines, self.Lines[i])
--     end
--     self.Lines = nLines
-- end

function Class.new()
    if not M.NsId then
        M.NsId = vim.api.nvim_create_namespace("ykm22.ns.BufLog")
        vim.api.nvim_set_hl(M.NsId, Class.StyleRed, { fg = "#fe6644" })
        vim.api.nvim_set_hl(M.NsId, Class.StyleGreen, { fg = "#99ffaa" })
        vim.api.nvim_set_hl(M.NsId, Class.StyleBlue, { fg = "#45b8c8" })
        vim.api.nvim_set_hl(M.NsId, Class.StyleYellow, { fg = "#facd1f" })
    end
    local ins = L.clone(M)

    return ins
end

return Class
