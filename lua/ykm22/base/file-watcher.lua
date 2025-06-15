local L = require("ykm22.base.lua-util")

---@type any
local uv = vim.uv

---@class ykm22.nvim.FileWatcher
local M = {
    ---@type string
    file = nil,
    ---@type fun(self:ykm22.nvim.FileWatcher)
    on_change = nil,

    ---@type fun(self:ykm22.nvim.FileWatcher)
    on_error = nil
}

function M:start_watch()
    self.handle = uv.new_fs_event()
    uv.fs_event_start(self.handle, self.file, {}, function (err,filename, events)
        if err then
            if self.on_error then
                self:on_error()
            else
                vim.notify("File Watch error: " .. self.file, vim.log.levels.ERROR)
                self:stop_watch()
            end
            return
        end

        print("File Watch: ", self.file , vim.inspect(events, {depth = 3}))
        
        if events.change then
            print("File change: " .. self.file)
            if self.on_change then
                self:on_change()
            end
        end
        
    end)

end

function M:is_watching()
    return self.handle ~= nil
end

function M:stop_watch()
    if self.handle then
        uv.fs_event_stop(self.handle)
        uv.close(self.handle)
        self.handle = nil
    end
end


return {
    new = function (file)
        local ins = L.clone(M)
        ins.file = file
        return ins
    end
}
