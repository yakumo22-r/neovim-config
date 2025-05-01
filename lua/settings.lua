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
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local path = vim.fn.expand("%:p")
        local stat = vim.loop.fs_stat(path)

        if vim.loop.fs_stat(path) then
            vim.api.nvim_buf_set_name(0, vim.loop.fs_realpath(path))
            vim.api.nvim_command("edit")
        end

        vim.fn.chdir(vim.loop.fs_realpath(vim.fn.getcwd()))
    end,
})

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
require('bufutils')
vim.api.nvim_set_keymap("v", "<leader>\"", ":lua YKM.bufu.SurroundSymbols('\\\"')<CR>", opt)
vim.api.nvim_set_keymap("v", "<leader>\'", ":lua YKM.bufu.SurroundSymbols('\\\'')<CR>", opt)
vim.api.nvim_set_keymap("v", "<leader>(", ":lua YKM.bufu.SurroundSymbols('(',')')<CR>", opt)
vim.api.nvim_set_keymap("v", "<leader>{", ":lua YKM.bufu.SurroundSymbols('{','}')<CR>", opt)
vim.api.nvim_set_keymap("v", "<leader>`", ":lua YKM.bufu.SurroundSymbols('`')<CR>", opt)

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
    -- 设置 ShaDa 文件目录
    local shada_dir
    if is_windows then
        shada_dir = vim.fn.expand('$LOCALAPPDATA/nvim-data/shada')
    else
        shada_dir = vim.fn.expand('~/.local/state/nvim/shada')
    end

    -- 检查目录是否存在
    if vim.fn.isdirectory(shada_dir) == 0 then
        vim.api.nvim_echo({{ 'ShaDa directory does not exist: ' .. shada_dir, 'WarningMsg' }}, false, {})
        return
    end

    -- 获取所有 .shada 文件
    local shada_files = vim.fn.glob(shada_dir .. '/main.shada*', false, true)

    if #shada_files == 0 then
        vim.api.nvim_echo({{ 'No ShaDa files found in: ' .. shada_dir, 'WarningMsg' }}, false, {})
        return
    end

    -- 删除每个 ShaDa 文件
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
-- vim.api.nvim_set_keymap("n", "<leader>t", ":lua require('filetree.filetree').toggle()<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>t", function ()
    -- require("msgwindow").Tip("test")
    require('filetree.filetree').toggle()
    
end, {noremap = true, silent = true})
-- vim.api.nvim_set_keymap("n", "<leader>t", ":lua require('filetree.filetree').toggle()<CR>", { noremap = true, silent = true })
