-- basics
-- make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add({
    extension = {
        zsh = "sh",
        sh = "sh", -- force sh-files with zsh-shebang to still get sh as filetype
    },
    filename = {
        [".zshrc"] = "sh",
        [".zshenv"] = "sh",
    },
})

-- surpport soft link
-- vim.api.nvim_create_autocmd("VimEnter", {
--     callback = function()
--         local path = vim.fn.expand("%:p")
--         local stat = vim.loop.fs_stat(path)

--         if vim.loop.fs_stat(path) then
--             vim.api.nvim_buf_set_name(0, vim.loop.fs_realpath(path))
--             vim.api.nvim_command("edit")
--         end

--         vim.fn.chdir(vim.loop.fs_realpath(vim.fn.getcwd()))
--     end,
-- })

-- highlight after copy
vim.api.nvim_create_autocmd({ "textyankpost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({
            timeout = 400,
        })

    end,
})

-- presistent undo
vim.cmd("set undofile")
vim.opt.undodir = vim.fn.stdpath("config") .. "/.tmp/undo"

-- disable automatic commenting on newline
vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = { "*" },
    command = "setlocal formatoptions-=c formatoptions-=r formatoptions-=o",
})

-- markdown shortkeys
local bind_markdown = require('markdown-keys')
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
    pattern = "*.md",
    callback = bind_markdown,
})

local opt = { noremap = true, silent = true }
local bufu = require('bufutils')

vim.api.nvim_set_keymap("v", "<leader>\"", bufu.SurroundSymbolsCMD('\\\"'), opt)
vim.api.nvim_set_keymap("v", "<leader>\'", bufu.SurroundSymbolsCMD('\\\''), opt)
vim.api.nvim_set_keymap("v", "<leader>(", bufu.SurroundSymbolsCMD('(',')',true), opt)
vim.api.nvim_set_keymap("v", "<leader>)", bufu.SurroundSymbolsCMD('(',')',false), opt)
vim.api.nvim_set_keymap("v", "<leader>{", bufu.SurroundSymbolsCMD('{','}',true), opt)
vim.api.nvim_set_keymap("v", "<leader>}", bufu.SurroundSymbolsCMD('{','}',false), opt)
vim.api.nvim_set_keymap("v", "<leader>`", bufu.SurroundSymbolsCMD('`'), opt)
vim.api.nvim_set_keymap("v", "<leader> ", bufu.SurroundSymbolsCMD(' '), opt)

vim.api.nvim_create_user_command('OpenInSystem', function()
    local filepath = vim.api.nvim_buf_get_name(0)

    if filepath == "" then
        print("No file associated with the current buffer")
        return
    end

    if vim.fn.has("mac") == 1 then
        vim.fn.system("open "..'"'..filepath..'"')
    elseif vim.fn.has("unix") == 1 then
        vim.fn.system("xdg-open "..'"'..filepath..'"')
    elseif vim.fn.has("win32") == 1 then
        vim.fn.system("start "..'"'..filepath..'"')
    else
        print("Unsupported system")
    end
end, {})

vim.api.nvim_create_user_command('ClearShada', function ()
    local is_windows = vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1
    local shada_dir
    if is_windows then
        shada_dir = vim.fn.expand('$LOCALAPPDATA/nvim-data/shada')
    else
        shada_dir = vim.fn.expand('~/.local/state/nvim/shada')
    end

    if vim.fn.isdirectory(shada_dir) == 0 then
        vim.api.nvim_echo({{ 'ShaDa directory does not exist: ' .. shada_dir, 'WarningMsg' }}, false, {})
        return
    end

    local shada_files = vim.fn.glob(shada_dir .. '/main.shada*', false, true)

    if #shada_files == 0 then
        vim.api.nvim_echo({{ 'No ShaDa files found in: ' .. shada_dir, 'WarningMsg' }}, false, {})
        return
    end

    for _, file in ipairs(shada_files) do
        if vim.fn.delete(file) == 0 then
            vim.api.nvim_echo({{ 'Deleted: ' .. file, 'None' }}, false, {})
        else
            vim.api.nvim_echo({{ 'Failed to delete: ' .. file, 'ErrorMsg' }}, false, {})
        end
    end
end, {desc = 'Clear all ShaDa files'})

vim.api.nvim_create_user_command('ClearCRLF', function ()
    vim.api.nvim_buf_call(0, function()
        vim.cmd('%s/\\r//g')
    end)
    vim.api.nvim_echo({{ 'Removed ^M from current buffer', 'None' }}, false, {})
end, {desc = 'Clear \r\n'})

-- Close syntax on big file
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
        if ok and stats then
            if stats.size > 1024 * 1024 then
                vim.treesitter.stop()
            end
            if stats.size > 2048 * 1024 then
                vim.bo.syntax = "off" -- Optional: also disable legacy syntax
            end
        end
    end,
})
