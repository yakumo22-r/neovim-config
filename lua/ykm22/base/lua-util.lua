local M = {}

---@generic T
---@param tbl T
---@return T
function M.clone(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local n = {}
    for k,v in pairs(tbl) do
        n[k] = M.clone(v)
    end
    return n
end


return M
