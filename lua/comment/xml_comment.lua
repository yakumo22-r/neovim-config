local cms = require("comment.pub_comment")
local cmstrs = require("comment.cmstrs")
local defu = cms.defu
local CMBF=2
local CMBE=3


local xml_u = {}
xml_u.fts = {"html","xml"}

function xml_u.init()

end

local cmbf = cmstrs.html[CMBF]
local cmbe = cmstrs.html[CMBE]
local l_cmbf = #cmbf
local l_cmbe = #cmbe

local function trimed_line(l)
    local c1 = 1
    local c2 = #l

    local c = l:sub(c1,c1)

    while c == " " or c == "\t" do
        c1=c1+1
        c=l:sub(c1,c1)
    end

    c = l:sub(c2,c2)
    while c == " " or c == "\t" do
        c2=c2-1
        c=l:sub(c2,c2)
    end

    return c1,c2,c
end

--- @param lines string[]
--- @return CmLine[]
function xml_u.check_cm_line(lines)
    ---@type CmLine[]
    local cmlines = {}

    mc1 = math.huge
    mc2 = 0

    for i, l in ipairs(lines) do
        local c1,c2,c = trimed_line(l)
        mc1 = math.min(mc1,c1)
        mc2 = math.max(mc2,c2)

        cmlines[i] = {c1=c1}
        if c ~= "" then
            cmlines[i].ignore = false
            cmlines[i].commented =
                l:sub(c1,c1+l_cmbf-1) == cmbf and
                l:sub(c2-l_cmbe+1, c2) == cmbe
        else
            cmlines[i].ignore = true
        end

        for _,v in ipairs(cmlines) do
            v.c1 = mc1
            v.c2 = mc2
        end
    end

    return cmlines
end

--- @param lines string[]
--- @param cmlines CmLine[]
function xml_u.cm_line(lines,cmlines)
    for i, l in ipairs(lines) do
        local cml = cmlines[i]
        if not cml.ignore then
            local c1 = cml.c1
            local c2 = cml.c2
            lines[i] = l:sub(1,c1-1) .. cmbf .. " " .. l:sub(c1,c2) .." ".. cmbe.. l:sub(c2+1)
        end
    end
end

--- @param lines string[]
--- @param cmlines CmLine[]
function xml_u.uncm_line(lines,cmlines)
    for i, l in ipairs(lines) do
        local cml = cmlines[i]
        if not cml.ignore and cml.commented then
            local c1 = cml.c1 + l_cmbf
            local c2 = cml.c2 - l_cmbe

            -- trim one space
            local c = l:sub(c1,c1)
            if c == " " then
                c1 = c1+1
            end
            c = l:sub(c2,c2)
            if c == " " then
                c2 = c2-1
            end
            lines[i] = l:sub(1,cml.c1-1)..l:sub(c1,c2)..l:sub(cml.c2+1)
        end
    end
end

function xml_u.check_cm_block(l1,l2,c1,c2)
    return defu.check_cm_block(l1,l2,c1,c2,"xml")
end

function xml_u.cm_block(l1,l2,c1,c2)
    return defu.cm_block(l1,l2,c1,c2,"xml")
end

function xml_u.uncm_block(l1,l2,c1,c2)
    return defu.uncm_block(l1,l2,c1,c2,"xml")
end

return xml_u
