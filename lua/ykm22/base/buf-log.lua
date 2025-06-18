local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")
local L = require("ykm22.base.lua-util")

-- TODO: 
-- Highlight [ ]

local NsId = vim.api.nvim_create_namespace("ykm22.ns.BufLog")


---@class ykm22.nvim.BufLog
local M = {
    NsId = NsId,
    Lines = {},
}

function M:is_show()
    return self.Buf and self.Win
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

        B.set_modifiable(self.Buf, true)
        B.set_lines(self.Buf, 1, -1, self.Lines)
        B.set_modifiable(self.Buf, false)

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
    vim.api.nvim_win_set_buf(self.Win, self.Buf)
    vim.api.nvim_win_set_hl_ns(self.Win, self.NsId)
    vim.api.nvim_set_option_value("winfixbuf", true, { win = self.Win })
end

function M:hide()
    if self.Win then
        vim.api.nvim_win_close(self.Win, false)
    end
end

function M:append(msgs)
    if #self.Lines > 400 then
        self:clear(100)
    end

    local lines = vim.tbl_map(vim.trim, vim.split(msgs, "\n"))

    local lineNum = #self.Lines + 1
    for _,line in ipairs(lines) do
        table.insert(self.Lines, line)
    end
    if self.Buf then
        B.set_modifiable(self.Buf, true)
        B.set_lines(self.Buf, lineNum, -1, lines)
        B.set_modifiable(self.Buf, false)
    end

    if self.Win then
        vim.api.nvim_win_set_cursor(self.Win, { lineNum + #lines - 1, 0 })
    end
end

function M:clear(lastNum)
    if self.Buf then
        B.set_modifiable(self.Buf, true)
        B.set_lines(self.Buf, 1, lastNum, {})
        B.set_modifiable(self.Buf, false)
    end
    local nLines = {}
    for i = lastNum + 1, #self.Lines do
        table.insert(nLines, self.Lines[i])
    end
    self.Lines = nLines
end

---@class ykm22.nvim.FloatLogClass
local Class = {}
function Class.new()
    local ins = L.clone(M)
    return ins
end

return Class
