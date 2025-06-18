local cms = require("comment.pub_comment")
cms.cover(require("comment.xml_comment"))
cms.cover(require("comment.vue_comment"))

local CM = 1
local CMBF = 2
local CMBE = 3
local CMF1 = 4
local CMF2 = 5

local function new_LOP(l1, l2)
    local LOP = {
        l1 = l1,
        l2 = l2,
        lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false),
    }

    function LOP:apply()
        vim.api.nvim_buf_set_lines(0, self.l1 - 1, self.l2, false, self.lines)
    end
    return LOP
end

local function normal_ops()
    local n = vim.v.count
    local l1 = vim.fn.line(".")
    local lop = new_LOP(l1, l1 + n)
    return cms.get(), lop
end

local function AddCommentNormal()
    local u, lop = normal_ops()
    local cmlines = u.check_cm_line(lop.lines)
    u.cm_line(lop.lines, cmlines)
    lop:apply()
end

local function RmCommentNormal()
    local u, lop = normal_ops()
    local cmlines = u.check_cm_line(lop.lines)
    u.uncm_line(lop.lines, cmlines)
    lop:apply()
end

local function ToggleCommentNormal()
    local u, lop = normal_ops()
    local cmlines, mode = u.check_cm_line(lop.lines)
    local mode_comment = cmlines[1].commented
    if not mode_comment then
        u.cm_line(lop.lines, cmlines)
    else
        u.uncm_line(lop.lines, cmlines)
    end
    lop:apply()
end

local function visual_ops()
    local u = cms.get()
    local mode = vim.fn.visualmode()

    if mode == "v" then
        local ps = vim.fn.getpos("'<")
        local pe = vim.fn.getpos("'>")
        local lines = vim.fn.getline(ps[2], pe[2])
        return u,ps[2],pe[2],ps[3],pe[3],lines,#lines,mode
    else
        local r1 = vim.fn.line("'<")
        local r2 = vim.fn.line("'>")
        local lines = vim.api.nvim_buf_get_lines(0, r1 - 1, r2, false)
        print(r1,r2)
        local ll = #lines
        return u,r1,r2,1,#(lines[ll]),lines,ll,mode
    end
end

local function ToggleCommentVisual()
    local u,r1,r2,c1,c2,lines,ll = visual_ops()
    local is_cm = false
    is_cm,c1,c2 = u.check_cm_block(lines[1],lines[ll],c1,c2)

    if is_cm then
        if ll == 1 then
            lines[1] ,_,c1,c2= u.uncm_block(lines[1], nil, c1, c2)
        else
            lines[1], lines[ll],c1,c2 = u.uncm_block(lines[1], lines[ll], c1, c2)
        end
    else
        if ll == 1 then
            lines[1] ,_,c1,c2= u.cm_block(lines[1], nil, c1, c2)
        else
            lines[1], lines[ll],c1,c2 = u.cm_block(lines[1], lines[ll], c1, c2)
        end
    end

    vim.fn.setline(r1, lines)

    vim.fn.setpos("'<", { 0, r1, c1, 0 })
    vim.fn.setpos("'>", { 0, r2, c2, 0 })
    vim.cmd("normal! gv")
end

local function AddCommentVisual()
    local u,r1,r2,c1,c2,lines,ll = visual_ops()

    is_cm,c1,c2 = u.check_cm_block(lines[1],lines[ll],c1,c2)
    if ll == 1 then
        lines[1] ,_,c1,c2= u.cm_block(lines[1], nil, c1, c2)
    else
        lines[1], lines[ll],c1,c2 = u.cm_block(lines[1], lines[ll], c1, c2)
    end

    vim.fn.setline(r1, lines)

    vim.fn.setpos("'<", { 0, r1, c1, 0 })
    vim.fn.setpos("'>", { 0, r2, c2, 0 })
    vim.cmd("normal! gv")
end

local function AddCommentVisual2()
    local u,r1,r2,c1,c2,lines,ll = visual_ops()
    local lop = new_LOP(r1, r2)
    local cmlines = u.check_cm_line(lop.lines)
    u.cm_line(lop.lines, cmlines)
    lop:apply()
end

local function RmCommentVisual()
    local u,r1,r2,c1,c2,lines,ll = visual_ops()
    local is_cm = false
    is_cm,c1,c2 = u.check_cm_block(lines[1],lines[ll],c1,c2)

    if is_cm then
        if ll == 1 then
            lines[1] ,_,c1,c2= u.uncm_block(lines[1], nil, c1, c2)
        else
            lines[1], lines[ll],c1,c2 = u.uncm_block(lines[1], lines[ll], c1, c2)
        end
    end

    vim.fn.setline(r1, lines)

    vim.fn.setpos("'<", { 0, r1, c1, 0 })
    vim.fn.setpos("'>", { 0, r2, c2, 0 })
    vim.cmd("normal! gv")
end

local function RmCommentVisual2()
    local u,r1,r2,c1,c2,lines,ll = visual_ops()
    local lop = new_LOP(r1, r2)
    local cmlines = u.check_cm_line(lop.lines)
    u.uncm_line(lop.lines, cmlines)
    lop:apply()
end

YKM22.CMD_Comment = {index = 0}
local function cmd(f)
    local m = YKM22.CMD_Comment
    m.index = m.index + 1
    m[m.index] = f
    return ":lua YKM22.CMD_Comment["..m.index.."]()<CR>"
end

local opt = { noremap = true, silent = true }
vim.keymap.set("n", "<C-_>", ToggleCommentNormal, opt)
vim.keymap.set("v", "<C-_>", cmd(ToggleCommentVisual), opt)
vim.keymap.set("n", "<C-/>", ToggleCommentNormal, opt)
vim.keymap.set("v", "<C-/>", cmd(ToggleCommentVisual), opt)

vim.keymap.set("v", "<leader>=", cmd(AddCommentVisual2), opt)
vim.keymap.set("v", "<leader>-", cmd(RmCommentVisual2), opt)

vim.keymap.set("n", "<leader>=", AddCommentNormal, opt)
vim.keymap.set("n", "<leader>-", RmCommentNormal, opt)

vim.keymap.set("v", "=", cmd(AddCommentVisual), opt)
vim.keymap.set("v", "-", cmd(RmCommentVisual), opt)

local function FastComment()
end

vim.keymap.set("i", "<C-=>",function ()
    local front = cms.get_cmstr(CMF1) or cms.get_cmstr(CM)
    local tail = cms.get_cmstr(CMF2) or ""
    r = " "
    if tail ~= "" then
        r = string.rep("<Left>", #tail) .. r
    end
    return front .. tail .. r
    
end,{noremap=true, silent = true, expr = true})
