local V = require("ykm22.base.view-api")
local floatMenu = require("ykm22.base.float-menu").new()

---@type ykm22.nvim.Sftp
local Handle = nil

---@class ykm22.nvim.SftpView
local M = {}

---@class ykm22.nvim.SftpViewConfig

-- TODO:
---@param files string[]
function M.take_group_by_git(files) end


---@return any
local function NvimTreeApi()
    local ok, api = pcall(require, "nvim-tree.api")

    if ok then
        return api
    end
end

---@return string[]
local function get_all_subfiles(dir)
    local files = vim.fn.readdir(dir)
    local rfiles = {}
    for _, file in ipairs(files) do
        local full_path = dir .. "/" .. file
        if vim.fn.isdirectory(full_path) == 1 then
            local subfiles = get_all_subfiles(full_path)
            for _, subfile in ipairs(subfiles) do
                table.insert(rfiles, subfile)
            end
        else
            table.insert(rfiles, vim.fs.relpath(Handle.get_root(), full_path))
        end
    end

    return rfiles
end

---@return string[]|nil
local function get_relative_files_on_buf(buf)
    local bufname = vim.api.nvim_buf_get_name(buf)
    local buftype = vim.bo[buf].buftype
    local path
    local isdir = false
    if buftype == "" then
        path = bufname
    elseif buftype == "nofile" then
        local api = NvimTreeApi()
        bufname = vim.fn.fnamemodify(bufname, ":p")
        if api and bufname:match("NvimTree_") then
            local node = api.tree.get_node_under_cursor()
            isdir = node.type == "directory"
            path = node.absolute_path
        end
    end

    if isdir then
        local files = get_all_subfiles(path)
        if #files > 0 then
            return files
        end
    elseif path then
        return { vim.fs.relpath(Handle.get_root(), path) }
    end
end

local Menu = {}
---@param text string
---@return ykm22.nvim.FloatMenuELement
function Menu.title(text)
    return {
        label = { V.style_cell(V.center_text(text, floatMenu.Width, "━"), 0, V.StyleInfo) },
    }
end

---@return ykm22.nvim.FloatMenuELement
function Menu.switchConf()
    local currConf = Handle.get_curr_conf()

    local cell = V.style_cell(string.format(" Switch(%s)", currConf.name))
    local cell2 = V.style_cell(V.right_text(" > ", floatMenu.Width - cell.width), 0, V.StyleOk)
    return {
        label = { cell, cell2 },
        action = function()
            floatMenu:set_list(Menu.confSelects("Switch Config", Handle.cmd_switch_conf))
            floatMenu:show()
            return false
        end,
    }
end

function Menu.testBtn()
    local width = floatMenu.Width
    local cell = V.style_cell(" testBtn")
    local cell2 = V.style_cell(V.right_text(" > ", width - cell.width), 0, V.StyleError)

    ---@type ykm22.nvim.FloatMenuELement
    return {
        label = { cell, cell2 },
        action = function(v)
            return true
        end,
    }
end

function Menu.edit_config()
    return {
        label = " Edit Config",
        action = function()
            vim.schedule(Handle.cmd_edit_sftp_conf)
            return true
        end,
    }
end

function Menu.reload_config()
    return {
        label = " Reload Config",
        action = function()
            Handle.cmd_init_sftp_conf()
            return true
        end,
    }
end

function Menu.upload()
    return {
        label = { V.style_cell(" Upload ") },
        action = function(v)
            local files = get_relative_files_on_buf(v.lastBuf)
            Handle.cmd_upload(nil, files)
            return true
        end,
    }
end


function Menu.upload_to()
    local cell = V.style_cell(" Upload to")
    local cell2 = V.style_cell(V.right_text(" > ", floatMenu.Width - cell.width), 0, V.StyleOk)
    return {
        label = { cell, cell2 },
        action = function(v)
            local files = get_relative_files_on_buf(v.lastBuf)
            local lists = Menu.confSelects("Upload to", function(_, name)
                if not name or name == "" then
                    return
                end
                local conf = Handle.get_conf_by_name(name)
                if not conf then
                    vim.notify("No such configuration: " .. name, vim.log.levels.ERROR)
                    return
                end
                Handle.cmd_upload(conf, files)
            end)
            floatMenu:set_list(lists)
            floatMenu:show()
        end,
    }
end


function Menu.sync() 
    return {
        label = { V.style_cell(" Sync ") },
        action = function(v)
            local files = get_relative_files_on_buf(v.lastBuf)
            Handle.cmd_sync(nil, files)
            return true
        end,
    }
end

function Menu.sync_from() 
    local cell = V.style_cell(" Sync from")
    local cell2 = V.style_cell(V.right_text(" > ", floatMenu.Width - cell.width), 0, V.StyleOk)
    return {
        label = { cell, cell2 },
        action = function(v)
            local files = get_relative_files_on_buf(v.lastBuf)
            local lists = Menu.confSelects("Upload to", function(_, name)
                if not name or name == "" then
                    return
                end
                local conf = Handle.get_conf_by_name(name)
                if not conf then
                    vim.notify("No such configuration: " .. name, vim.log.levels.ERROR)
                    return
                end
                Handle.cmd_sync(conf, files)
            end)
            floatMenu:set_list(lists)
            floatMenu:show()
        end,
    }
end

---@param title string
---@param e fun(_,name:string)
---@return ykm22.nvim.FloatMenuELement[]
function Menu.confSelects(title, e)
    local confs = Handle.get_confs()
    local currConf = Handle.get_curr_conf()

    local eles = { Menu.title(title) }
    for _, conf in ipairs(confs) do
        local text
        if conf.name == currConf.name then
            text = string.format("(*) %s", conf.name)
            text = { V.style_cell(text, 0, V.StyleOk) }
        else
            text = string.format("%s", conf.name)
        end

        table.insert(eles, {
            label = text,
            action = function()
                if currConf.name ~= conf.name then
                    e(nil, conf.name)
                end
                return true
            end,
        })
    end

    return eles
end

function M.show_float_ops()
    ---@type ykm22.nvim.FloatMenuELement[]
    local menus = {
        Menu.title(" SFTP Menu "),
    }

    floatMenu.MinusRange[1] = 1
    if not Handle.get_curr_conf() then
        table.insert(menus, {
            label = V.center_text(" SftpInitConf", floatMenu.Width),
            action = function()
                Handle.cmd_init_sftp_conf()
                return true
            end,
        })
    else
        table.insert(menus, Menu.upload())
        table.insert(menus, Menu.sync())
        table.insert(menus, Menu.switchConf())
        table.insert(menus, Menu.upload_to())
        table.insert(menus, Menu.sync_from())
        table.insert(menus, Menu.reload_config())
    end

    floatMenu:set_list(menus)
    floatMenu:show()
end

---@param handle ykm22.nvim.Sftp
function M.setup(handle)
    Handle = handle
    vim.keymap.set("n", "<leader>u", M.show_float_ops, { noremap = true, silent = true })
end

return M
