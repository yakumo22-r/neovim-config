local lsp_base = {}
function lsp_base.cmd(cmd)
    if vim.fn.has("win32") == 1 then
        return vim.fn.stdpath("data").."\\mason\\bin\\"..cmd..".cmd"
    else
        return cmd
    end
end 

---@class yakumo22.LspEntity
local LspEntity = {}

---@param pattern string[]
function LspEntity:ctor(pattern)
    ---@type integer[]
    self.waitbufs = {}

    ---@type string[]
    self.patterns = pattern

    self.patternMap = {}
    for _,p in ipairs(pattern) do
        self.patternMap[p] = true
    end

    self.enable = false
end

---@param buf integer
function LspEntity:filetype_match(buf)
    return 
end

function LspEntity:init()
    vim.api.nvim_create_autocmd("FileType",{
        pattern = self.patterns,
        callback = function (args)
            if not self.enable then
                table.insert(self.waitbufs, args.buf)
                return
            end
            self:attach_buf(args.buf)
        end,
    })

    local buf = vim.api.nvim_get_current_buf()
    if self.patternMap[vim.bo[buf].filetype] then
        table.insert(self.waitbufs, buf)
    end
end

---@param buf integer
function LspEntity:attach_buf(buf)
    vim.notify("Not implement "..tostring(buf), vim.log.levels.ERROR)
end

---@param capabilities function?
---@param keybindings fun(client:vim.lsp.Client,buf:integer)
function LspEntity:set_enable(capabilities, keybindings)
    self.capabilities = capabilities
    self.keybindings = keybindings
    self.enable = true
    for _,buf in ipairs(self.waitbufs) do
        self:attach_buf(buf)
    end
    self.waitbufs = {}
end

---@param pattern string[] pattern
---@return yakumo22.LspEntity
function lsp_base.new_entity(pattern)
    ---@class yakumo22.LspEntity
    local ins = {}
    for k,v in pairs(LspEntity) do
        ins[k] = v
    end
    ins:ctor(pattern)
    return ins
end

return lsp_base

