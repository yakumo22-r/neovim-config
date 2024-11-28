local cms = require("comment.pub_comment")
local cmstrs = require("comment.cmstrs")
local defu = cms.defu
local xml_u = require("comment.xml_comment")

local MsgWindow = require("msgwindow")

---@return boolean|any
local function azure_ts_utils()
    local ok,err = pcall(require, "nvim-treesitter.ts_utils")

    if not ok then
        MsgWindow.Tip("CommentError:Vue", {err}, MsgWindow.StyleError)
        return false
    end

    return err
end

local function get_cursor_language()
    -- this file require treessiter
    ts_utils = azure_ts_utils()

    if not ts_utils then
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, col = cursor[1] - 1, cursor[2]

    local node = ts_utils.get_node_at_cursor()
    if not node then
        return "unknown"
    end

    local language_tree = vim.treesitter.get_parser(bufnr):language_for_range({row, col, row, col})
    if not language_tree then
        return "unknown"
    end

    return language_tree:lang()
end

local vue_u = {}
vue_u.fts = { "vue" }
function vue_u.init()

end


function vue_u.check_cm_line(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.check_cm_line(...)
    end
    return defu.check_cm_line(...)
end

function vue_u.cm_line(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.cm_line(...)
    end
    return defu.cm_line(...)
end

function vue_u.uncm_line(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.uncm_line(...)
    end
    return defu.uncm_line(...)
end

function vue_u.check_cm_block(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.check_cm_block(...)
    end
    return defu.check_cm_block(...)
end

function vue_u.cm_block(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.cm_block(...)
    end
    return defu.cm_block(...)
end

function vue_u.uncm_block(...)
    local lang = get_cursor_language()
    if not lang then
        return
    end
    if lang == "vue" or lang == "html"  then
        return xml_u.uncm_block(...)
    end
    return defu.uncm_block(...)
end

return vue_u
