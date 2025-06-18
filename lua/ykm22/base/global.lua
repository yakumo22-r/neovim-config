if not ykm22 then
    ykm22 = {}
end

---@param dir string
---@param root? string
---@return string[]
function ykm22.get_all_subfiles(dir,root)
    local files = vim.fn.readdir(dir)
    local rfiles = {}
    for _, file in ipairs(files) do
        local full_path = dir .. "/" .. file
        if vim.fn.isdirectory(full_path) == 1 then
            local subfiles = ykm22.get_all_subfiles(full_path)
            for _, subfile in ipairs(subfiles) do
                table.insert(rfiles, subfile)
            end
        else
            if root then
                table.insert(rfiles, vim.fs.relpath(root, full_path))
            else
                table.insert(rfiles, full_path)
            end
        end
    end

    return rfiles
end


return ykm22
