local CM = 1
local CMBF = 2
local CMBE = 3
local CMF1 = 4
local CMF2 = 5
local cmstrs = {
    default = {
        [CM] = "//",
        [CMBF] = "/*",
        [CMBE] = "*/",
        [CMF1] = "/**",
        [CMF2] = " */",
    },
    lua = {
        [CM] = "--",
        [CMBF] = [[--[[]],
        [CMBE] = " --]]",
    },
    html = {
        [CMBF] = "<!--",
        [CMBE] = "-->",
        [CMF1] = "<!--",
        [CMF2] = " -->",
    },
    vim = { '"' },
    sh = { "#" },
}

cmstrs.python = cmstrs.sh
cmstrs.bash = cmstrs.sh
cmstrs.zsh = cmstrs.sh
cmstrs.conf = cmstrs.sh
cmstrs.xml = cmstrs.html
cmstrs.nginx = cmstrs.sh

function cmstrs.can_cm_line(ft)
    ft = ft or vim.bo.filetype
    local cmp = cmstrs[ft]
    if cmp then
        return cmp[CM] and cmp[R_CM]
    end
    return true
end

function cmstrs.can_cm_block()
    local ft = vim.bo.filetype
    local cmp = cmstrs[ft]
    if cmp then
        return cmp[CMBF] and cmp[CMBE]
    end
    return true
end

return cmstrs
