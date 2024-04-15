local T = {}

function T.cxx_compile_flags(info)
    local project_config_file = Tool.get_current_directory()
        .. "/compile_flags.txt"
    file = io.open(project_config_file, "w")
    if file then
        file:write(info.exec .. "\n")
        for i, v in ipairs(info.sources) do
            file:write(v .. "\n")
        end
        for i, v in ipairs(info.args) do
            file:write(v .. "\n")
        end
        file:close()
    else
        print("cannot open file for writting: " .. project_config_file)
    end
end

function T.combine_cmds(info)
    local str = info.exec.." "
    for i, v in ipairs(info.sources) do
        str = str .. v .. " "
    end
    for i, v in ipairs(info.args) do
        str = str .. v .. " "
    end
    return str
end

return T
