local ffi = require("ffi")

ffi.cdef([[
typedef struct
{
    int code;
    const char* msg;
} LibsftpResult;

typedef struct
{
    int state;
    int code;
    const char* msg;
} LibsftpAsyncResult;

typedef void* libsftp_async_handle;
typedef void* libsftp_async_con;

libsftp_async_handle libsftp_make_async_handle();
void libsftp_del_async_handle(libsftp_async_handle ah);
LibsftpResult libsftp_err_async_handle(libsftp_async_handle ah);
libsftp_async_con libsftp_async_start(libsftp_async_handle ah, const char* hostname, int port, const char* username, const char* password);

void libsftp_async_upload(libsftp_async_con ac, const char* local, const char* remote);
void libsftp_async_done(libsftp_async_con ac);
LibsftpAsyncResult libsftp_async_state(libsftp_async_con ac);
void libsftp_async_close(libsftp_async_con ac);
]])

local libsftp = ffi.load(local_c_lib("libsftp"))

local M = {}

function M:create_conection(info, on_exit)
    if type(info.hostname) ~= "string" or type(info.port) ~= "number" or type(info.username) ~= "string" or type(info.password) ~= "string" then
        print(string.format("paramters error: %s: %s, %s: %s, %s: %s %s: %s"))
        return nil
    end

    local handler = libsftp.libsftp_async_start(self.async_handle, info.hostname, info.port, info.username, info.password)
    local timer = vim.loop.new_timer()

    timer:start(100, 100, function()
        local state = libsftp.libsftp_async_state(handler)
        if state.state >= 1 then
            print(string.format("continue code: %d, %s", state.code, state.code == 0 and "success" or c_str(state.msg)))
            -- 继续运行
        elseif state.state <= 0 then
            -- 结束标识
            libsftp.libsftp_async_close(handler)
            print(string.format("result code: %d, %s", state.code, state.code == 0 and "success" or c_str(state.msg)))
            if type(on_exit == "function") then
                on_exit(state.code)
            end
            vim.loop.timer_stop(timer)
        end
    end)

    --libsftp.libsftp_async_done(handler)
    return {
        handler = handler,
        upload_file = function(self, _local, _remote)
            libsftp.libsftp_async_upload(self.handler, _local, _remote)
        end,

        done = function(self)
            libsftp.libsftp_async_done(self.handler)
        end,
    }
end

function M:init()
    if not self.async_handle then
        self.async_handle = libsftp.libsftp_make_async_handle()
        local res = libsftp.libsftp_err_async_handle(self.async_handle)
        res.msg = c_str(res.msg)
        if res.code ~= 0 then
            print(res.msg .. " code: " .. res.code)
        end
        return res
    end
end

function M:exit()
    if self.async_handle then
        libsftp.libsftp_del_async_handle(self.async_handle)
    end
end

return M
