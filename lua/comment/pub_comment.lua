local cms = {}

local CM=1
local CMBF=2
local CMBE=3

local cmstrs = require("comment.cmstrs")
cms.defstr=cmstrs.default

local defu = {}
function cms.get_cmstr(t, ft)
    ft = ft or vim.bo.filetype
    if cmstrs[ft] then
        return cmstrs[ft][t]
    end
    return cmstrs.default[t]
end

---@class CmLine
---@field ignore? boolean
---@field commented? boolean
---@field c1 number
---@field c2? number

-- multi lines comment check
--- @param lines string[]
--- @return CmLine[]
function defu.check_cm_line(lines)
    local cm = cms.get_cmstr(CM)
    local l_cm = #cm

    ---@type CmLine[]
    local cmlines = {}

    local mc1 = math.huge

    for i, line in ipairs(lines) do
        local c1 = 1
        local c = line:sub(c1,c1)
        while c==" " or c == "\t" do
            c1 = c1+1
            c = line:sub(c1,c1)
        end
        mc1 = math.min(c1,mc1)

        cmlines[i] = {c1=c1}
        if c ~= "" then
            cmlines[i].ignore = false
            cmlines[i].commented = line:sub(c1,c1+l_cm-1) == cm
        else
            cmlines[i].ignore = true
        end
    end

    for _,v in ipairs(cmlines) do
        v.c1 = mc1
    end

    return cmlines
end

--- @param lines string[]
--- @param cmlines CmLine[]
function defu.cm_line(lines, cmlines)
    local cm = cms.get_cmstr(CM)
    for i, l in ipairs(lines) do
        if not cmlines[i].ignore then
            local c1 = cmlines[i].c1
            lines[i] = l:sub(1,c1-1) .. cm .. " " .. l:sub(c1)
        end
    end
end

--- @param lines string[]
--- @param cmlines CmLine[]
function defu.uncm_line(lines, cmlines)
    local cm = cms.get_cmstr(CM)
    local l_cm = #cm
    for i, l in ipairs(lines) do
        local cml = cmlines[i]
        if not cml.ignore and cml.commented then
            -- trim one space
            local c2 = cml.c1 + l_cm
            local c = l:sub(c2,c2)
            if c == " " then
                c2 = c2+1
            end
            lines[i] = l:sub(1,cml.c1-1)..l:sub(c2)
        end
    end
end

function defu.check_cm_block(l1,l2,c1,c2,ft)
    local cmbf = cms.get_cmstr(CMBF,ft)
    local cmbe = cms.get_cmstr(CMBE,ft)

    local c = l1:sub(c1,c1)
    while c == " " or c == "\t" do
        c1=c1+1
        c=l1:sub(c1,c1)
    end

    c = l2:sub(c2,c2)
    while c == " " or c == "\t" do
        c2=c2-1
        c=l2:sub(c2,c2)
    end

    local l_cmbf = #cmbf
    local l_cmbe = #cmbe
    local fword = l1:sub(c1, c1+l_cmbf-1)
    local eword = l2:sub(c2-l_cmbe+1, c2)

    local is_cm = fword == cmbf and eword == cmbe
    return is_cm,c1,c2
end

function defu.cm_block(l1,l2,c1,c2,ft)
    local cmbf = cms.get_cmstr(CMBF,ft)
    local cmbe = cms.get_cmstr(CMBE,ft)
    local l_cmbf = #cmbf
    local l_cmbe = #cmbe
    if not l2 then
        l1 = l1:sub(1,c1-1)..cmbf..l1:sub(c1,c2)..cmbe..l1:sub(c2+1)
        return l1,l1,c1,c2+l_cmbf+l_cmbe
    end

    l1 = l1:sub(1,c1-1)..cmbf..l1:sub(c1)
    l2 = l2:sub(1,c2)..cmbe..l2:sub(c2+1)
    return l1,l2,c1,c2+l_cmbe
end

function defu.uncm_block(l1,l2,c1,c2,ft)
    local cmbf = cms.get_cmstr(CMBF,ft)
    local cmbe = cms.get_cmstr(CMBE,ft)
    local l_cmbf = #cmbf
    local l_cmbe = #cmbe
    if not l2 then
        l1 = l1:sub(1,c1-1)..l1:sub(c1+l_cmbf,c2-l_cmbe)..l1:sub(c2+1)
        return l1,l1,c1,c2-l_cmbf-l_cmbe
    end
    l1 = l1:sub(1,c1-1)..l1:sub(c1+l_cmbf)
    l2 = l2:sub(1,c2-l_cmbe)..l2:sub(c2+1)
    return l1,l2,c1,c2-l_cmbe
end

cms.defu = defu
local covers = {}

function cms.get()
    local ft = vim.bo.filetype
    if covers[ft] then
        return covers[ft]
    end
    return defu
end

function cms.cover(u)
    u.init()
    for _,k in ipairs(u.fts) do
        covers[k] = u
    end
end

return cms
