require("base_func")
local wu = require "window.window_util"
local api = vim.api
---@class FT_TreeLines
---@field line string -- show
---@field node FT_Node
---@field list boolean -- direct list


---@class FT_View
local ins = {}


---@type integer
ins.tree_wnd = 0

---@type integer
ins.buf = 0

---@type FT_Handler
ins.ft_handler = nil

---@type FT_TreeLines[]
ins.lines = {}

function ins:refresh()
    local lines = {}
    for _,v in ipairs(self.lines) do
        table.insert(lines, v.line)
    end
    wu.set_modifiable(self.buf, true)
    api.nvim_buf_set_lines(self.buf, 0,-1,false,lines)
    wu.set_modifiable(self.buf, false)
end

---@param node FT_Node
local function filename_to_line(node)
    if node.type ~= "file" then
        return node.name .. "/"
    end

    return node.name
end

---@param lines FT_TreeLines[]
---@param datas FT_Node[]
local function build_lines(lines,datas,id)
    level = level or 0
    local ca = {}

    local n_id = 1
    local l_id = 1

    local node_num = #datas

    while n_id < node_num do
        local node = datas[n_id]
        local line = lines[l_id]

        if node then
            -- insert new
            if node.line_id == -1 then
                -- insert new
                table.insert(lines,l_id,{
                    line = filename_to_line(node),
                    node = node,
                    list = false,
                })
                l_id = l_id+1
            elseif node.line_id == -2 then
                if line and line.node == node then
                    -- remove one
                    table.remove(line,l_id)
                end
            else
                line.line = filename_to_line(node)
                line.node = node
                l_id = l_id+1
            end

        end
        n_id = n_id+1
    end
end

---@param ft_handler FT_Handler
local function New__FT_View(ft_handler)
    ---@type FT_View
    local v = table.clone(ins)
    v.buf = api.nvim_create_buf(false, true)
    wu.block_edit_keys(v.buf)
    wu.set_only_read(v.buf)
    api.nvim_set_option_value("buftype", "nofile", {buf=v.buf})
    build_lines(v.lines, ft_handler.datas)

    v:refresh()

    return v
end

return New__FT_View
