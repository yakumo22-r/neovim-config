local stru = {}

function stru.trim_one(str)
    if string.sub(str, 1, 1) == " " then
        return string.sub(str, 2)
    else
        return str
    end
end

return stru 

