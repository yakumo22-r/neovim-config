vim.cmd("command! -nargs=* InitFormatter lua YKM22.InitFormatter(<f-args>)")

local maps = {
    cpp = ".clang-format",
    json = ".prettierrc.json",
    lua = ".stylua.toml",
}

local function copy_files(name)
    local configpath = vim.fn.stdpath("config")
    local formatpath = configpath .. "/formatrc/" .. name
    local target = vim.fn.getcwd() .. "/" .. name
    os.execute('cp "' .. formatpath .. '" "' .. target .. '"')
end

function YKM22.InitFormatter(...)
    local args = { ... }
    if #args == 0 then
        for k, v in pairs(maps) do
            copy_files(v)
        end
    else
        for i, v in ipairs(args) do
            if maps[v] then
                copy_files(maps[v])
            end
        end
    end
end

