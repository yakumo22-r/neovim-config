local script_dir = vim.fn.expand("<sfile>:p:h")
function local_c_lib(name)
    if vim.fn.has("win32") == 1 then
        return string.format("%s\\lib\\win32\\%s.dll", script_dir, name)
    else
        return string.format("%s/lib/linux/%s.so", script_dir, name)
    end
end

function c_str(cstr, default)
    local ffi = require("ffi")
    if cstr ==  ffi.NULL then
        return default
    else
        return ffi.string(cstr)
    end
end

--local ffi = require("ffi")
--ffi.cdef([[
--void* tp_create();
--void tp_add(void* handle, int i);
--int tp_state(void* handle);
--void tp_delete(void* handle);
--]])
--
--local test = ffi.load(local_c_lib("testplug"))
function test_func()
    local sftp = require("sftp")
    sftp:init()
    local handle = sftp:create_conection({
        username = "root",
        password = "xytest@root02.xy20201231",
        port = 22,
        hostname = "120.79.29.215",
    }, function ()
        sftp:exit()
    end)

    --handle:done()

end


vim.cmd("command! PTEST lua test_func()")
