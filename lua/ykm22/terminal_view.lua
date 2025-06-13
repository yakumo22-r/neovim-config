local T = require("ykm22.terminal")

---@class ykm22.TerminalView
local M = {}

local ManagerBuf = -1
local ManagerWin = -1
local Buf2Line = {}
local ManagerHidden = true
local BaseLineNum = 0

local icons = {
    "🐠 ",
    "🐋",
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
    "🕷️",
    "🕸️",
    "🦂",
    "🦟",
    "🦠",
}

function M.RefreshTermManager()
    local lines = {
        "━━━━ Terminal Manager ━━━━",
        "  🌹Enter/o: Open",
        "  🌴r: Rename",
        "  🌿d: Delete",
        "  ❌q: Quit",
        "  🍁n: New Terminal",
        "━━━━━━━━━━━━━━━━━━━━━━━━━━",
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
        return a.alias < b.alias
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
    vim.api.nvim_buf_set_lines(ManagerBuf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = ManagerBuf })

    vim.api.nvim_buf_clear_namespace(ManagerBuf, -1, 0, -1)
    vim.api.nvim_buf_add_highlight(ManagerBuf, -1, "TermManageTitle", 0, 0, -1) -- Title
    for i = 1, BaseLineNum do
        vim.api.nvim_buf_add_highlight(ManagerBuf, -1, "TermManageNew", i, 0, -1) -- New Terminal
    end
    for i = BaseLineNum, line_num - 1 do
        vim.api.nvim_buf_add_highlight(ManagerBuf, -1, "TermManageList", i, 0, -1) -- Terminals
    end

    if ManagerHidden or ManagerWin < 0 then
        vim.api.nvim_command("vsplit")
        ManagerWin = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(ManagerWin, ManagerBuf)
        vim.api.nvim_win_set_width(ManagerWin, 30)
        vim.api.nvim_set_option_value("winfixwidth", true, { win = ManagerWin })
        vim.api.nvim_create_autocmd("WinClosed", {
            pattern = tostring(ManagerWin),
            callback = function()
                ManagerHidden = true
                ManagerWin = -1
            end,
        })

        ManagerHidden = false
    end

    if line_num == BaseLineNum then
        vim.api.nvim_win_set_cursor(ManagerWin, { BaseLineNum - 1, 0 })
    else
        vim.api.nvim_win_set_cursor(ManagerWin, { BaseLineNum + 1, 0 })
    end
end

function M.OpenTermManager()
    ManagerBuf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = ManagerBuf })
    vim.api.nvim_set_option_value("filetype", "termmanage", { buf = ManagerBuf })

    -- Define highlights
    vim.api.nvim_set_hl(0, "TermManageTitle", { fg = "#fab387", bold = true })
    vim.api.nvim_set_hl(0, "TermManageShort", { fg = "#FF8866", bold = true })
    vim.api.nvim_set_hl(0, "TermManageList", { fg = "#f5c0b2" })
    vim.api.nvim_set_hl(0, "TermManageNew", { fg = "#d5d39b", italic = true })

    -- Key mappings
    local function map(key, action)
        vim.api.nvim_buf_set_keymap(ManagerBuf, "n", key, "", {
            callback = action,
            noremap = true,
            silent = true,
        })
    end

    for _, key in ipairs({ "r", "p", "v", "i", "u", "c", "x","V", "<C-v>"}) do
        vim.api.nvim_buf_set_keymap(ManagerBuf, "n", key, "<Nop>", { noremap = true, silent = true })
    end

    -- Listen for specific buffer events
    vim.api.nvim_create_autocmd({ "BufHidden", "BufDelete" }, {
        buffer = ManagerBuf, -- 0 means current buffer, or specify buffer number
        callback = function(ev)
            local buf = ev.buf
            if ev.event == "BufHidden" then
                ManagerHidden = true
            elseif ev.event == "BufDelete" then
                ManagerHidden = true
                ManagerBuf = -1
            end
        end,
    })

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

    map("n", NewTerm)

    -- Enter/o: Open terminal or create new
    map("<CR>", Enter)
    map("o", Enter)

    -- r: Rename terminal
    map("r", function()
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
    map("d", function()
        local lnum = vim.api.nvim_win_get_cursor(0)[1]
        if Buf2Line[lnum] then
            local alias = T.termAlaias[Buf2Line[lnum]]
            T.TermDelete(alias)
            M.RefreshTermManager()
        end
    end)

    -- q: Quit
    map("q", function()
        vim.api.nvim_command("hide")
    end)

    M.RefreshTermManager()
end

function M.ToggleTermManager()
    if ManagerBuf == -1 then
        M.OpenTermManager()
    else
        if not ManagerHidden then
            vim.api.nvim_set_current_buf(ManagerBuf)
            vim.api.nvim_command("hide")
        else
            M.RefreshTermManager()
        end
    end
end

vim.keymap.set("n", "<C-t>", M.ToggleTermManager, { noremap = true, silent = true })

return M
