local T = require("ykm22.terminal")
local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")

---@class ykm22.TerminalView
local M = {}

local ManagerBuf = -1
local ManagerWin = -1
local Buf2Line = {}
local ManagerHidden = true
local BaseLineNum = 0
local NsId = -1

local icons = {
    "🐠 ",
    "🐋 ",
    "🐬 ",
    "🐳 ",
    "🐟 ",
    "🐡 ",
    "🦈 ",
    "🐙 ",
    "🦑 ",
    "🦐 ",
    "🦞 ",
    "🦀 ",
    "🐚 ",
    "🐢 ",
    "🐍 ",
    "🦎 ",
    "🦖 ",
    "🦕 ",
    "🐉 ",
    "🐲 ",
    "🐾 ",
    "🦋 ",
    "🐛 ",
    "🐜 ",
    "🐝 ",
    "🐞 ",
    "🦗 ",
    "🕷️ ",
    "🕸️ ",
    "🦂 ",
    "🦟 ",
    "🦠 ",

}

local Width = 30
local BufWidth = 26

function M.RefreshTermManager()
    if ManagerHidden or ManagerWin < 0 then
        vim.api.nvim_command("vsplit")
        ManagerWin = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(ManagerWin, ManagerBuf)
        vim.api.nvim_win_set_width(ManagerWin, Width)
        -- vim.api.nvim_set_option_value("winfixwidth", true, { win = ManagerWin })
        vim.api.nvim_win_set_hl_ns(ManagerWin, NsId)
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(ManagerWin),
            callback = function()
                ManagerHidden = true
                ManagerWin = -1
            end,
        })

        ManagerHidden = false
    end

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

    Buf2Line = {}
    local line_num = #lines
    BaseLineNum = line_num
    local map = {}
    for bufnr, alias in pairs(T.termAlaias) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            table.insert(map, { alias = alias, bufnr = bufnr })
        end
    end

    table.sort(map, function(a, b)
        return a.bufnr < b.bufnr
    end)

    for _, entry in ipairs(map) do
        local iconId = entry.bufnr % #icons + 1
        local line = string.format(" %sterm://%s buf(%d)", icons[iconId], entry.alias, entry.bufnr)
        table.insert(lines, line)
        line_num = line_num + 1
        Buf2Line[line_num] = entry.bufnr
    end


    -- Set buffer content
    vim.api.nvim_set_option_value("modifiable", true, { buf = ManagerBuf })
    B.set_lines(ManagerBuf, 1, -1, lines)
    vim.api.nvim_buf_set_lines(ManagerBuf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = ManagerBuf })

    -- vim.api.nvim_buf_clear_namespace(ManagerBuf, -1, 0, -1)

    V.set_hl(ManagerBuf, NsId, "TermManageTitle", {1,1})
    V.set_hl(ManagerBuf, NsId, "TermManageShort", {2,1,BaseLineNum})
    V.set_hl(ManagerBuf, NsId, "TermManageList", {BaseLineNum,1,line_num})

    vim.api.nvim_buf_set_extmark(ManagerBuf, NsId, 1, 0, {
        end_line = BaseLineNum,
        end_col = 0,
        hl_group = "TermManageShort",
        strict = false,
    })

    vim.api.nvim_buf_set_extmark(ManagerBuf, NsId, BaseLineNum, 0, {
        end_line = line_num,
        end_col = 0,
        hl_group = "TermManageList",
        strict = false,
    })

    if line_num == BaseLineNum then
        vim.api.nvim_win_set_cursor(ManagerWin, { BaseLineNum - 1, 0 })
    else
        vim.api.nvim_win_set_cursor(ManagerWin, { BaseLineNum + 1, 0 })
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
    if Buf2Line[lnum] then
        vim.api.nvim_command("hide")
        vim.api.nvim_set_current_buf(Buf2Line[lnum])
    elseif lnum == BaseLineNum - 1 then
        NewTerm()
    end
end

function M.OpenTermManager()
    NsId = vim.api.nvim_create_namespace('ykm22.TerminalManager')

    ManagerBuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = ManagerBuf })
    vim.api.nvim_set_option_value("filetype", "termmanage", { buf = ManagerBuf })

    -- Define highlights
    -- vim.api.nvim_set_hl(0, "TermManageTitle", { fg = "#ffff00", bold = true })
    vim.api.nvim_set_hl(NsId, "TermManageTitle", { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(NsId, "TermManageShort", { fg = "#FF8866", bold = true })
    vim.api.nvim_set_hl(NsId, "TermManageList", { fg = "#f5c0b2" })

    -- Listen for specific buffer events
    vim.api.nvim_create_autocmd({ "BufHidden", "BufDelete" }, {
        buffer = ManagerBuf, -- 0 means current buffer, or specify buffer number
        callback = function(ev)
            if ev.event == "BufHidden" then
                ManagerHidden = true
            elseif ev.event == "BufDelete" then
                ManagerHidden = true
                ManagerBuf = -1
            end
        end,
    })

    B.block_edit_keys(ManagerBuf)

    B.bind_key(ManagerBuf, "n", NewTerm)
    B.bind_key(ManagerBuf, "<CR>", Enter)
    B.bind_key(ManagerBuf, "o", Enter)
    -- r: Rename terminal
    B.bind_key(ManagerBuf, "r", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        if Buf2Line[lnum] then
            vim.ui.input({ prompt = "Enter new alias: " }, function(input)
                if input and input ~= "" then
                    T.set_term_alias(Buf2Line[lnum], input)
                    M.RefreshTermManager()
                end
            end)
        end
    end)

    -- d: Delete terminal
    B.bind_key(ManagerBuf, "d", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        if Buf2Line[lnum] then
            local alias = T.termAlaias[Buf2Line[lnum]]
            T.TermDelete(alias)
            M.RefreshTermManager()
        end
    end)

    -- q: Quit
    B.bind_key(ManagerBuf, "q", function()
        vim.api.nvim_command("hide")
    end)

    M.RefreshTermManager()
end

function M.ToggleTermManager()
    if ManagerBuf == -1 then
        M.OpenTermManager()
    else
        if not ManagerHidden then
            vim.api.nvim_win_close(ManagerWin, false)
        else
            M.RefreshTermManager()
        end
    end
end

vim.keymap.set("n", "<C-t>", M.ToggleTermManager, { noremap = true, silent = true })

return M
