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

vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function ()
        require('markdown-keys')
    end,
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
