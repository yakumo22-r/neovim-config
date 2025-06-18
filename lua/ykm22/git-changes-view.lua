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
---@type any
local Buf = nil
---@type any
local Win = nil
local IsRefreshing = false

---@type string[]
local NeedUploadFiles = {}

local Width = 50
local BufWidth = 46

local StyleTitle = "StyleTitle"
local StyleCmd = "StyleCmd"
local StyleInfo = "StyleInfo"
local StyleLine = "StyleLine"
local StylePath = "StylePath"
local StyleDir = "StyleDir"
local StyleLoading = "StyleLoading"

function M.get_buf()
    return Buf
end

---@type string
local _root = nil

---@class ykm22.nvim.GitChangeNode
---@field path string
---@field mode string
---@field isdir boolean?
---@field moveSrc string?

---@type ykm22.nvim.GitChangeNode[]
local GitNodes = {}

---@param line string
local function parse_git_changes(line)
    local mode = line:sub(1,2)

    ---@type string
    local path

    line = line:sub(4)
    local index
    if line:sub(1,1) == '"' then
        index = line:find('"', 2)
    else
        index = line:find(' ', 2)
    end
    path = line:sub(1, index)
    local moveSrc
    if mode:sub(1,1) == "R" then
        line = line:sub(index + 5)
        moveSrc = path
        if line:sub(1,1) == '"' then
            index = line:find('"', 2)
        else
            index = line:find(' ', 2)
        end
        moveSrc = path
        path = line:sub(1, index)
    end

    ---@type ykm22.nvim.GitChangeNode
    local v = {
        name = vim.fn.fnamemodify(path, ':t'),
        path = path,
        mode = mode,
        isdir = path:sub(#path) == "/",
        moveSrc = moveSrc,
    }

    -- print(">>>>>>>>>>>",line)
    -- for k,vv in pairs(v) do
    --     print(k, vv)
    -- end
    -- print("<<<<<<<<<<<")

    return v
end

function M.refresh_git_changes()
    IsRefreshing = true
    M.RefreshView()
    CmdPip.run("git", { "status", "--porcelain" }, function(m)
        if not m then
            IsRefreshing = false
            GitNodes = {}
            NeedUploadFiles = {}
            M.RefreshView()
            return
        end
        local files = {}
        local lines = vim.split(m, "\n", { trimempty = true })
        GitNodes = {}
        NeedUploadFiles = {}
        for _, line in ipairs(lines) do
            local node = parse_git_changes(line)
            table.insert(GitNodes, node)
        end

        IsRefreshing = false
        -- print("Git changes:", vim.inspect(files))
        M.RefreshView()
    end, _root)
end

---@parma node ykm22.nvim.GitChangeNode
---@param paths string[]
---@param root? string
local function get_git_node_path(node, paths, root)
    if not node.mode:match("^[MAR? ][MA? ]") then
        return
    end
    if node.isdir then
        local files = ykm22.get_all_subfiles(_root .. "/" .. node.path, root)
        for _,f in ipairs(files) do
            table.insert(paths, f)
        end
    else
        if root then
            table.insert(paths, vim.fs.relpath(root, _root .. "/" .. node.path))
        else
            table.insert(paths, _root .. "/" .. node.path)
        end
    end
end

---@return string[]
---@param root? string
function M.get_cursor_abs_paths(root)
    local lnum = vim.api.nvim_win_get_cursor(Win)[1]
    local index = Line2Index[lnum]
    local r = {}
    if index and GitNodes[index] then
        get_git_node_path(GitNodes[index], r, root)
    end
    return r
end

---@return string[]
---@param root string
function M.get_need_upload_files(root)
    if not NeedUploadFiles[1] then
        for _, node in ipairs(GitNodes) do
            get_git_node_path(node, NeedUploadFiles, root)
        end
    end
    return NeedUploadFiles
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

---@param gitNode ykm22.nvim.GitChangeNode
local function gitnode_to_line(gitNode)
    ---@type ykm22.nvim.StyleCell[]
    local cells = {}
    table.insert(cells, V.style_cell(gitNode.mode, 0, StyleCmd))

    if gitNode.isdir then
        table.insert(cells, V.style_cell("  ", 0, StyleDir))
        table.insert(cells, V.style_cell(gitNode.path, 0, StyleDir))
    else
        local filename = vim.fn.fnamemodify(gitNode.path, ':t')
        local icon,style = V.get_icon_style(filename)
        table.insert(cells, V.style_cell(string.format(" %s ", icon), 0, style))
        table.insert(cells, V.style_cell(filename.." "))
        if gitNode.moveSrc then
            table.insert(cells, V.style_cell(gitNode.moveSrc .. " ", 0, StylePath))
            table.insert(cells, V.style_cell("-> ", 0, StyleCmd))
        end
        table.insert(cells, V.style_cell(gitNode.path, 0, StylePath))
    end
    return V.get_style_line(cells)
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
    local lineStyles = {}
    for i=1,line_num do
        table.insert(lineStyles, false)
    end

    for i, node in ipairs(GitNodes) do
        local line, styles = gitnode_to_line(node)
        table.insert(lines, line)
        table.insert(lineStyles, styles)
        line_num = line_num + 1
        Line2Index[line_num] = i
    end

    B.set_modifiable(Buf, true)
    B.set_lines(Buf, StaticLineNum + 1, -1, lines)
    V.set_extmark(Buf, NsId, styleR, { StaticLineNum + 1, 1 })
    V.set_extmark(Buf, NsId, StyleLine, { StaticLineNum + 2, 1, line_num + 1, 1 })
    for i, styles in ipairs(lineStyles) do
        if styles then
            V.set_styles(Buf, NsId, i, styles)
        end
    end
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
    local path = M.get_cursor_abs_paths()[1]
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

    vim.api.nvim_set_hl(NsId, StyleTitle, { fg = "#45b8c8" })
    vim.api.nvim_set_hl(NsId, StyleCmd, { fg = "#fe6644" })
    vim.api.nvim_set_hl(NsId, StyleInfo, { fg = "#e5de42" })
    vim.api.nvim_set_hl(NsId, StyleLoading, { fg = "#ef90e2" })
    vim.api.nvim_set_hl(NsId, StyleLine, { fg = "#e6d2bc" })
    vim.api.nvim_set_hl(NsId, StylePath, { fg = "#aa9999" })
    vim.api.nvim_set_hl(NsId, StyleDir, { fg = "#facd1f" })

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
