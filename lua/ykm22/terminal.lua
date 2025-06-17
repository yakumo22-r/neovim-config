local B = require("ykm22.base.buf-api")

---@class ykm22.Terminal
local M = {}

---@type table<integer, string>
M.termAlaias = {}
M.termNames = {}
M.termCount = 0

defaultTerm = -1

function M.set_term_alias(bufnr, alias)
    if M.termNames[alias] and M.termNames[alias] ~= bufnr then
        vim.notify("Alias '" .. alias .. "' is already in use by another terminal.", vim.log.levels.ERROR)
        return
    end

    M.termNames[alias] = bufnr
    M.termAlaias[bufnr] = alias

    vim.api.nvim_buf_set_name(bufnr, "term://" .. alias) -- Set buffer name
    vim.bo[bufnr].buflisted = false -- Hide from TabLine
end

-- Get alias by buffer number
function M.get_term_alias(bufnr)
    return M.termAlaias[bufnr] or "Unnamed"
end


---@type string?
M.next_term_alias = nil
function M.set_next_term_alias(alias)
    M.next_term_alias = alias
end

-- Create autocommand for TermOpen
vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "term://*", -- Match terminal buffers
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if defaultTerm == -1 then
            defaultTerm = bufnr
        end
        if not M.termAlaias[bufnr] then
            if M.next_term_alias then
                M.set_term_alias(bufnr, M.next_term_alias)
                M.next_term_alias = nil
            else
                M.termCount = M.termCount + 1
                M.set_term_alias(bufnr, tostring(M.termCount))
            end
        end
        local opts = { buffer = bufnr, noremap = true, silent = true }
        vim.keymap.set("n", "<C-t>", function ()
            vim.cmd('bprevious')
        end, opts)
        vim.schedule(function ()
            vim.cmd("startinsert")
        end)
    end, -- Call the function
    group = vim.api.nvim_create_augroup("TerminalKeymaps", { clear = true }), -- Autocommand group to avoid duplicates
})

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "term://*",
    callback = function()
        vim.cmd("startinsert")
    end,
})

vim.api.nvim_create_autocmd("BufDelete", {
    pattern = "term://*",
    callback = function()
        local bufnr = vim.api.nvim_get_current_buf()
        if vim.api.nvim_buf_is_valid(bufnr) then
            return
        end
        if bufnr == M.defaultTerm then
            M.defaultTerm = -1
        end
        local name = M.termAlaias[bufnr]
        if name then
            M.termNames[name] = nil
            M.termAlaias[bufnr] = nil
        end
    end,
})

function M.TermLs(notip)
    local lines = {}
    if not notip then
        table.insert(lines, "Terminals:")
    end
    for bufnr, alias in pairs(M.termAlaias) do
        table.insert(lines, string.format("term://%s - buf(%d)", alias, bufnr))
    end
    return table.concat(lines, "\n")
end

function M.TermSwitch(alias)
    for bufnr, term_alias in pairs(M.termAlaias) do
        if term_alias == alias and vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_set_current_buf(bufnr)
            return
        end
    end
    vim.notify("No terminal found with alias: " .. alias, vim.log.levels.ERROR)
end

function M.TermDelete(alias)
    for bufnr, term_alias in pairs(M.termAlaias) do
        if term_alias == alias and vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_buf_delete(bufnr, { force = true })
            M.termAlaias[bufnr] = nil
            M.termNames[alias] = nil
            return
        end
    end
    vim.notify("No terminal found with alias: " .. alias, vim.log.levels.ERROR)
end

-- Command: :TermAlias <alias> - Set custom alias
vim.api.nvim_create_user_command("TermAs", function(opts)
    M.set_term_alias(vim.api.nvim_get_current_buf(), opts.args)
end, { nargs = 1 })

-- Command: :TermList - List all terminals
vim.api.nvim_create_user_command("TermLs", M.TermLs, {})

-- Command: :TermSwitch <alias> - Switch to terminal by alias
vim.api.nvim_create_user_command("TermSwitch", function(opts)
    M.TermSwitch(opts.args)
end, {
    nargs = 1,
    complete = function()
        return vim.tbl_keys(M.termAlaias)
    end,
})

vim.api.nvim_create_user_command("TermDelete", function(opts)
    M.TermDelete(opts.args)
end, {
    nargs = 1,
    complete = function()
        return vim.tbl_keys(M.termAlaias)
    end,
})

vim.api.nvim_create_user_command("Term", function()
    for bufnr, alias in pairs(M.termAlaias) do
        if vim.api.nvim_buf_is_valid(bufnr) then
            vim.api.nvim_set_current_buf(bufnr)
            return
        end
    end
    vim.notify("No terminal avaliable", vim.log.levels.ERROR)
end, {})

local index = 0
local function ToggleTerm()
    index = index + 1
    if vim.bo.buftype == "terminal" then
        return
    else
        print(index, "ToggleTerm: Not a terminal buffer")
    end
    if defaultTerm == -1 then
        vim.cmd("terminal")
        return
    else
        vim.api.nvim_win_set_buf(0, defaultTerm)
    end
end

vim.keymap.set("n", "<C-t>", ToggleTerm, B.opts)
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], B.opts)
vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], B.opts)
vim.keymap.set("t", "<C-t>", function ()
    vim.cmd('bprevious')
end, B.opts)

return M
