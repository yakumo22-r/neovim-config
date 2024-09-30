local bufu = require("bufutils")

local md_prefix = {
    [0] = { c = "", r = "" },
    [1] = { c = "# ", r = "#+%s" },
    [2] = { c = "## ", r = "" },
    [3] = { c = "### ", r = "" },
    [4] = { c = "#### ", r = "" },
    [5] = { c = "##### ", r = "" },
    [6] = { c = "###### ", r = "" },

    [17] = { c = "> ", r = ">+%s" },
    [18] = { c = "- ", r = "[%-%*%+]%s" },
    [19] = { c = "- [ ] ", r = "^%- %[ %]%s" },
    [20] = { c = "- [x] ", r = "^%- %[x%]%s" },
    [21] = { c = "- [x] ", r = "%-%s%[[%sx]%]%s" },
}
YKM.md_prefix = md_prefix

local markdu = {}
YKM.markdu = markdu

local function ClearPrefix(line)
    line = bufu.RmLinePrefix(line,md_prefix[1].r)
    line = bufu.RmLinePrefix(line,md_prefix[21].r)
    line = bufu.RmLinePrefix(line,md_prefix[17].r)
    line = bufu.RmLinePrefix(line,md_prefix[18].r)
    return line
end

function markdu.format_to(i)
    local line = vim.api.nvim_get_current_line()
    vim.api.nvim_set_current_line(md_prefix[i].c..ClearPrefix(line))
end

function markdu.formats_to(id)
    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    local prefix = md_prefix[id].c

    for i, line in ipairs(lines) do
        line = ClearPrefix(line)
        lines[i] = prefix..line
    end

    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.api.nvim_win_set_cursor(0, { line1, 0 })
    vim.fn.setpos("'>", { 0, line2, 0, 0 })
end

function markdu.header_level(num)
   local line = vim.api.nvim_get_current_line()

   local cur_level = 0

   local match = string.match(line,md_prefix[1].r)
   if match then
       cur_level = #match-1
   end

   cur_level = cur_level + num

   while cur_level < 0 do
       cur_level = cur_level + 7
   end

   while cur_level > 6 do
       cur_level = cur_level - 7
   end

   print(cur_level)
   vim.api.nvim_set_current_line(md_prefix[cur_level].c..ClearPrefix(line))
end

function markdu.checkbox_toggle()
    local line = vim.api.nvim_get_current_line()
    if string.match(line, md_prefix[19].r) then
        line = string.sub(line,#(md_prefix[19].c)+1)
        line = md_prefix[20].c..line
    elseif string.match(line, md_prefix[20].r) then
        line = string.sub(line,#(md_prefix[20].c)+1)
        line = md_prefix[19].c..line
    else
        line = ClearPrefix(line)
        line = md_prefix[19].c..line
    end
    vim.api.nvim_set_current_line(line)
end

function markdu.checkboxs_toggle()
    local line1 = vim.fn.line("'<")
    local line2 = vim.fn.line("'>")
    local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)

    for i, line in ipairs(lines) do
        if string.match(line, md_prefix[19].r) then
            line = string.sub(line,#(md_prefix[19].c)+1)
            lines[i] = md_prefix[20].c..line
        elseif string.match(line, md_prefix[20].r) then
            line = string.sub(line,#(md_prefix[20].c)+1)
            lines[i] = md_prefix[19].c..line
        else
            line = ClearPrefix(line)
            lines[i] = md_prefix[19].c..line
        end
    end
    
    vim.api.nvim_buf_set_lines(0, line1 - 1, line2, false, lines)
    vim.api.nvim_win_set_cursor(0, { line1, 0 })
    vim.fn.setpos("'>", { 0, line2, 0, 0 })
end

local opt = { noremap = true, silent = true }
local function set(...)
    vim.api.nvim_buf_set_keymap(0, ...)
end

set("n", "<leader>0", ":lua YKM.markdu.format_to(0)<CR>", opt)
set("v", "<leader>0", ":lua YKM.markdu.formats_to(0)<CR>", opt)

set("n", "<leader>1", ":lua YKM.markdu.format_to(1)<CR>", opt)
set("n", "<leader>2", ":lua YKM.markdu.format_to(2)<CR>", opt)
set("n", "<leader>3", ":lua YKM.markdu.format_to(3)<CR>", opt)
set("n", "<leader>4", ":lua YKM.markdu.format_to(4)<CR>", opt)
set("n", "<leader>5", ":lua YKM.markdu.format_to(5)<CR>", opt)
set("n", "<leader>6", ":lua YKM.markdu.format_to(6)<CR>", opt)

set("n", "<leader>]", ":lua YKM.markdu.header_level(1)<CR>", opt)
set("n", "<leader>[", ":lua YKM.markdu.header_level(-1)<CR>", opt)

set("n", "<leader>.", ":lua YKM.markdu.format_to(17)<CR>", opt)
set("v", "<leader>.", ":lua YKM.markdu.formats_to(17)<CR>", opt)

set("v", "<leader>u", ":lua YKM.markdu.formats_to(18)<CR>", opt)
set("n", "<leader>u", ":lua YKM.markdu.format_to(18)<CR>", opt)

set("v", "<leader>x", ":lua YKM.markdu.checkboxs_toggle()<CR>", opt)
set("n", "<leader>x", ":lua YKM.markdu.checkbox_toggle()<CR>", opt)
