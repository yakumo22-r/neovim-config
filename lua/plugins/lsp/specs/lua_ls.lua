local config_dir = vim.fn.stdpath('config')
local lsp_base = require 'plugins.lsp.tools.lsp_base'

local lua_clients = {
    default = nil,
    nvim = nil,
    xmake = nil,
}

local settings = {}

settings.default = {
    runtime = {
        version = "LuaJIT",
        path = {
            "?.lua",
            "?.lua.txt",
            "?/init.lua",
            "?/init.lua.txt",
        },
    },
    diagnostics = {
        disable = { "lowercase-global", "trailing-space", "empty-block" },
    },
}

settings.nvim = vim.tbl_deep_extend("keep", settings.default, {
    diagnostics = {
        globals = { "vim" },
    },
    workspace = {
        library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.stdpath("config") .. "/lua"] = true,
        },
    },
})

settings.xmake = vim.tbl_deep_extend("keep", settings.default, {
    workspace = {
        library = {
            [vim.fn.expand(vim.fn.fnamemodify(config_dir, ":h") .. "/xmake_docs")] = true,
        },
    },
})

local _lspconfig
local _capabilities
local _keybindings
local function attach_client(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local t = "default"
    if filename:match("xmake.lua$") then
        t = "xmake"
    elseif filename:sub(1,#config_dir)==config_dir then
        t = "nvim"
    end

    if not lua_clients[t] then
        lua_clients[t] = vim.lsp.start({
            name = "lua_" .. t,
            cmd = { lsp_base.cmd("lua-language-server") },
            capabilities = vim.tbl_deep_extend("keep", _capabilities, {
                workspace = {
                    configuration = true,
                },
            }),
            on_init = function(client)
                vim.lsp.buf_attach_client(bufnr, lua_clients[t])
            end,
            on_attach = function(client, bufnr)
                _keybindings(client, bufnr)
            end,
            single_file_support = true,
            settings = {
                Lua = settings[t],
            },
        })
    else
        vim.lsp.buf_attach_client(bufnr, lua_clients[t])
    end
end

local wait_bufs = {}
return function(lspconfig, capabilities, keybindings)
    if lspconfig ~= nil then
        _lspconfig = lspconfig
        _capabilities = capabilities
        _keybindings = keybindings
        for _, v in ipairs(wait_bufs) do
            attach_client(v)
        end
        wait_bufs = {}
        return
    end

    if vim.bo.filetype == "lua" then
        table.insert(wait_bufs, vim.api.nvim_get_current_buf())
    end
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
        pattern = {"*.lua", "*.lua.txt"},
        callback = function(args)
            if not _lspconfig then
                if vim.bo.filetype == "lua" then
                    table.insert(wait_bufs, args.buf)
                end
                return
            end
            attach_client(args.buf)
        end,
    })
end
