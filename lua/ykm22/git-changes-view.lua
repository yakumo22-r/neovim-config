require("ykm22.base.global")
local V = require("ykm22.base.view-api")
local B = require("ykm22.base.buf-api")
local CmdPip = require("ykm22.base.cmd-pip")
local NvimTreeWrap = require("ykm22.base.nvim-tree-wrap")

---@class ykm22.nvim.GitChangeView
local M = {}
ykm22.GitChangeView = M

local NsId = vim.api.nvim_create_namespace("ykm22.GitChanges")
local Line2Index = {}

---@type fun(file:string,_, _):string?,string
local _readCfg = nil

local StaticLineNum = 0
---@type string[]
local Lines = {}
local Files = {}
---@type any
local Buf = nil
---@type any
local Win = nil
local IsRefreshing = false

local Width = 30
local BufWidth = 26

local StyleTitle = "StyleTitle"
local StyleCmd = "StyleCmd"
local StyleInfo = "StyleInfo"
local StyleLine = "StyleLine"
local StyleLoading = "StyleLoading"

function M.get_buf()
    return Buf
end

---@type string
local _root = nil

function M.refresh_git_changes()
    IsRefreshing = true
    M.RefreshView()
    CmdPip.run("git", { "status", "--porcelain" }, function(m)
        if not m then
            IsRefreshing = false
            Lines = {}
            Files = {}
            M.RefreshView()
            return
        end
        local files = {}
        local lines = vim.split(m, "\n", { trimempty = true })
        for _, line in ipairs(lines) do
            if line:match("^[AM?]") ~= "" then
                table.insert(files, line:sub(4))
            end
        end
        -- TODO: parse directory
        Lines = lines
        Files = files
        IsRefreshing = false
        -- print("Git changes:", vim.inspect(files))
        M.RefreshView()
    end, _root)
end
local sep = package.config:sub(1, 1)
function M.get_cursor_abs_path()
    local lnum = vim.api.nvim_win_get_cursor(Win)[1]
    if Line2Index[lnum] then
        return _root .. sep .. Files[Line2Index[lnum]]
    end
end

function M.get_change_files()
    return Files
end

local Line2Buf = {}

function M.OpenWindow()
    vim.api.nvim_command("botright vsplit")
    Win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(Win, Buf)
    vim.api.nvim_win_set_width(Win, Width)
    vim.api.nvim_set_option_value("winfixbuf", true, { win = Win })
    vim.api.nvim_win_set_hl_ns(Win, NsId)
end

function M.RefreshView()
    if not Win then
        M.OpenWindow()
    end

    local lines = {}

    local styleR = StyleInfo
    if IsRefreshing then
        local loadingLine = V.center_text(" Refreshing... ", BufWidth, "━")
        styleR = StyleLoading
        table.insert(lines, loadingLine)
    else
        local loadingLine = V.center_text(" List ", BufWidth, "━")
        table.insert(lines, loadingLine)
    end

    local line_num = StaticLineNum + 1
    Line2Index = {}
    for i, line in ipairs(Lines) do
        table.insert(lines, line)
        line_num = line_num + 1
        Line2Index[line_num] = i
    end

    B.set_modifiable(Buf, true)
    B.set_lines(Buf, StaticLineNum + 1, -1, lines)
    V.set_extmark(Buf, NsId, styleR, { StaticLineNum + 1, 1 })
    V.set_extmark(Buf, NsId, StyleLine, { StaticLineNum + 2, 1, line_num + 1, 1 })
    B.set_modifiable(Buf, false)

    if line_num == StaticLineNum then
        vim.api.nvim_win_set_cursor(Win, { StaticLineNum, 0 })
    else
        vim.api.nvim_win_set_cursor(Win, { StaticLineNum + 1, 0 })
    end
end

local function StaticView()
    local lines = {}
    local styleLines = {}
    local styles
    local styLine = V.center_text(" Git-Changes ", BufWidth, "━")
    table.insert(lines, styLine)
    table.insert(styleLines, false)

    styLine, styles = V.get_style_line({ V.style_cell("  Enter/o:", 0, StyleCmd), V.style_cell(" Open", 1, StyleInfo) })
    table.insert(lines, styLine)
    table.insert(styleLines, styles)

    styLine, styles = V.get_style_line({ V.style_cell("  r:", 0, StyleCmd), V.style_cell(" Refresh", 1, StyleInfo) })
    table.insert(lines, styLine)
    table.insert(styleLines, styles)

    styLine, styles = V.get_style_line({ V.style_cell("  q:", 0, StyleCmd), V.style_cell(" Quit", 1, StyleInfo) })
    table.insert(lines, styLine)
    table.insert(styleLines, styles)

    StaticLineNum = #lines
    B.set_modifiable(Buf, true)
    B.set_lines(Buf, 1, StaticLineNum, lines)
    B.set_modifiable(Buf, false)

    V.set_extmark(Buf, NsId, StyleTitle, { 1, 1 })
    for i, lineStyles in ipairs(styleLines) do
        if lineStyles then
            V.set_styles(Buf, NsId, i, lineStyles)
        end
    end
end

 
local function Enter()
    if not NvimTreeWrap.useable() then
        vim.notify("nvim-tree is not available. Please install it.", vim.log.levels.ERROR)
        return
    end
    local path = M.get_cursor_abs_path()
    if path then
        local file_wins = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].buftype == "" then
                table.insert(file_wins, { win = win, buf = buf })
            end
        end
        local num = #file_wins

        NvimTreeWrap.edit(path)
    end
end

function M.RefreshLayout()
    if not Win or not vim.api.nvim_win_is_valid(Win) then
        return
    end
    -- vim.schedule(function ()
        local current_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(Win)
        vim.api.nvim_command('wincmd L')
        -- vim.api.nvim_win_set_config(Win, { relative = "", col = vim.o.columns - Width })
        vim.api.nvim_win_set_width(Win, Width)
        vim.api.nvim_set_current_win(current_win)
    -- end)
end

function M.OpenView()
    Buf = vim.api.nvim_create_buf(false, true)
    B.set_buf_nofile(Buf)
    vim.api.nvim_buf_set_name(Buf, "Git Changes")

    vim.api.nvim_set_hl(NsId, StyleTitle, { fg = "#45a8a8" })
    vim.api.nvim_set_hl(NsId, StyleCmd, { fg = "#fe6644" })
    vim.api.nvim_set_hl(NsId, StyleInfo, { fg = "#e5de42" })
    vim.api.nvim_set_hl(NsId, StyleLoading, { fg = "#ef90e2" })
    vim.api.nvim_set_hl(NsId, StyleLine, { fg = "#f5c0b2" })

    B.autocmds(Buf, {"WinClosed", "WinNew"}, function(ev)
        if ev.event == "WinNew" then
            M.RefreshLayout()
        else
            Win = nil
        end
    end)

    StaticView()

    B.autocmds(Buf, { "BufHidden", "BufDelete" }, function (ev)
        if ev.event == "BufDelete" then
            B.clear_buf_autocmds(Buf)
            Buf = nil
        end
        Win = nil
    end)

    B.block_fast_keys(Buf)

    -- q: Quit
    B.bind_key(Buf, "q", function()
        vim.api.nvim_command("hide")
    end)

    B.bind_key(Buf, "r", M.refresh_git_changes)
    B.bind_key(Buf, "<CR>", Enter)
    B.bind_key(Buf, "o", Enter)

    M.RefreshView()
end

function M.ToggleView()
    if not Buf then
        M.OpenView()
        M.refresh_git_changes()
    else
        if Win then
            vim.api.nvim_win_close(Win, false)
        else
            M.RefreshView()
        end
    end
end

---@param readCfg fun(file:string,_, _):string?,string
function M.setup(readCfg)
    _readCfg = readCfg
    vim.api.nvim_create_user_command("GitChangeView", M.ToggleView, {})
    vim.keymap.set("n", "<C-g>", M.ToggleView, B.opts)
end

function M.init(root)
    _root = root
end

return M
