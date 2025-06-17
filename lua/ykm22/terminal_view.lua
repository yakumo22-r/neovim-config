require("ykm22.base.global")
local T = require("ykm22.terminal")
local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")
---@class ykm22.TerminalView
local M = {}

ykm22.TerminalManagerView = M

local Buf = -1
local Win = -1
local Line2Buf = {}
local Hidden = true
local StaticLineNum = 0
local NsId = -1

-- stylua: ignore start
local icons = { "🐠 ", "🐋 ", "🐬 ", "🐳 ", "🐟 ", "🐡 ", "🦈 ", "🐙 ", "🦑 ", "🦐 ", "🦞 ", "🦀 ", "🐚 ", "🐢 ", "🐍 ", "🦎 ", "🦖 ", "🦕 ", "🐉 ", "🐲 ", "🐾 ", "🦋 ", "🐛 ", "🐜 ", "🐝 ", "🐞 ", "🦗 ", "🕷️ ", "🕸️ ", "🦂 ", "🦟 ", "🦠 ", }
-- stylua: ignore end

local StyleTitle = "StyleTitle"
local StyleCmd = "StyleCmd"
local StyleInfo = "StyleInfo"

local Width = 30
local BufWidth = 26

function M.RefreshTermManager()
    if Hidden or Win < 0 then
        vim.api.nvim_command("botright vsplit")
        Win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(Win, Buf)
        vim.api.nvim_win_set_width(Win, Width)
        -- vim.api.nvim_set_option_value("winfixwidth", true, { win = Win })
        vim.api.nvim_win_set_hl_ns(Win, NsId)
        vim.api.nvim_create_autocmd("WinClosed", {
            buffer = Buf,
            callback = function()
                Hidden = true
                Win = -1
            end,
        })

        Hidden = false
    end

    Line2Buf = {}
    local map = {}
    for bufnr, alias in pairs(T.termAlaias) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            table.insert(map, { alias = alias, bufnr = bufnr })
        end
    end

    table.sort(map, function(a, b)
        return a.bufnr < b.bufnr
    end)

    local line_num = StaticLineNum
    local lines = {}
    for _, entry in ipairs(map) do
        local iconId = entry.bufnr % #icons + 1
        local line = string.format(" %sterm://%s buf(%d)", icons[iconId], entry.alias, entry.bufnr)
        table.insert(lines, line)
        line_num = line_num + 1
        Line2Buf[line_num] = entry.bufnr
    end

    if line_num > StaticLineNum then
        -- Set buffer content
        B.set_modifiable(Buf, true)
        B.set_lines(Buf, StaticLineNum + 1, -1, lines)
        B.set_modifiable(Buf, false)
        V.set_extmark(Buf, NsId, StyleInfo, { StaticLineNum + 1, 1, line_num+1, 1 })
    end

    if line_num == StaticLineNum then
        vim.api.nvim_win_set_cursor(Win, { StaticLineNum - 1, 0 })
    else
        vim.api.nvim_win_set_cursor(Win, { StaticLineNum + 1, 0 })
    end
end

local function NewTerm()
    vim.ui.input({ prompt = "Enter new alias: " }, function(input)
        if input and input ~= "" and not T.termNames[input] then
            T.set_next_term_alias(input)
            vim.api.nvim_command("hide")
            vim.api.nvim_command("terminal")
        end
    end)
end

local function Enter()
    local lnum = vim.api.nvim_win_get_cursor(0)[1]
    if Line2Buf[lnum] then
        vim.api.nvim_command("hide")
        vim.api.nvim_set_current_buf(Line2Buf[lnum])
    elseif lnum == StaticLineNum - 1 then
        NewTerm()
    end
end

local function StaticView()
    local title = V.center_text(" Terminal Manager ", BufWidth, "━")
    local sep = V.center_text("", BufWidth, "━")
    local lines = {
        title,
        "  🌹Enter/o: Open",
        "  🌴r: Rename",
        "  🌿d: Delete",
        "  ❌q: Quit",
        "  🍁n: New Terminal",
        sep,
    }
    StaticLineNum = #lines

    B.set_modifiable(Buf, true)
    B.set_lines(Buf, 1, StaticLineNum, lines)
    B.set_modifiable(Buf, false)

    V.set_extmark(Buf, NsId, StyleTitle, { 1, 1 })
    V.set_extmark(Buf, NsId, StyleCmd, { 2, 1, StaticLineNum + 1, 1 })
end

function M.OpenTermManager()
    NsId = vim.api.nvim_create_namespace("ykm22.TerminalManager")

    Buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = Buf })
    vim.api.nvim_set_option_value("filetype", "termmanage", { buf = Buf })

    -- Define highlights
    vim.api.nvim_set_hl(NsId, StyleTitle, { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(NsId, StyleCmd, { fg = "#FF8866", bold = true })
    vim.api.nvim_set_hl(NsId, StyleInfo, { fg = "#f5c0b2" })

    StaticView()

    -- Listen for specific buffer events
    vim.api.nvim_create_autocmd({ "BufHidden", "BufDelete" }, {
        buffer = Buf, -- 0 means current buffer, or specify buffer number
        callback = function(ev)
            if ev.event == "BufHidden" then
                Hidden = true
            elseif ev.event == "BufDelete" then
                Hidden = true
                Buf = -1
            end
        end,
    })

    B.block_fast_keys(Buf)

    B.bind_key(Buf, "n", NewTerm)
    B.bind_key(Buf, "<CR>", Enter)
    B.bind_key(Buf, "o", Enter)
    -- r: Rename terminal
    B.bind_key(Buf, "r", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        if Line2Buf[lnum] then
            vim.ui.input({ prompt = "Enter new alias: " }, function(input)
                if input and input ~= "" then
                    T.set_term_alias(Line2Buf[lnum], input)
                    M.RefreshTermManager()
                end
            end)
        end
    end)

    -- d: Delete terminal
    B.bind_key(Buf, "d", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        if Line2Buf[lnum] then
            local alias = T.termAlaias[Line2Buf[lnum]]
            T.TermDelete(alias)
            M.RefreshTermManager()
        end
    end)

    -- q: Quit
    B.bind_key(Buf, "q", function()
        vim.api.nvim_command("hide")
    end)

    M.RefreshTermManager()
end

function M.ToggleTermManager()
    if Buf == -1 then
        M.OpenTermManager()
    else
        if not Hidden then
            vim.api.nvim_win_close(Win, false)
        else
            M.RefreshTermManager()
        end
    end
end

vim.keymap.set("n", "<leader>t", M.ToggleTermManager, { noremap = true, silent = true })

return M
