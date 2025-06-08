-- _G.Telescope = {}
local Custom = {}

function Custom.config()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    local tb = require("telescope.builtin")

    Custom.make_entry = require("telescope.make_entry")
    Custom.utils = require("telescope.utils")
    Custom.strings = require("plenary.strings")
    Custom.entry_display = require("telescope.pickers.entry_display")

    local lsp_opt = {
        entry_maker = Custom.make_entry_text,
        theme = "dropdown",
        layout_strategy = "horizontal",
        layout_config = { width = 0.95, height = 0.95 },
    }

    telescope.setup({
        defaults = {
            path_display = { "truncate" },
            mappings = {
                i = {
                    ["<C-k>"] = actions.move_selection_previous, -- move to prev result
                    ["<C-j>"] = actions.move_selection_next, -- move to next result
                },
                n = {
                    ["<C-j>"] = actions.cycle_history_next, -- next history
                    ["<C-k>"] = actions.cycle_history_prev, -- prev history
                },
            },
            vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--trim", -- add this value
            },
        },
        pickers = {
            live_grep = {
                theme = "dropdown",
                layout_strategy = "horizontal",
                layout_config = { width = 0.95, height = 0.95 },
            },

            lsp_references = lsp_opt,
            lsp_definitions = lsp_opt,
            lsp_implementations = lsp_opt,
            lsp_type_definitions = lsp_opt,

            find_files = {
                -- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
                -- find_command = { "fd", "--type", "f", "--strip-cwd-prefix", "--hidden" },
                fuzzy = false,
                sorter = require("telescope.sorters").get_fzy_sorter({}),
                use_regex = false,
                theme = "dropdown",
                previewer = false,
                layout_config = { width = 0.6, height = 0.8 },
            },
            grep_string = {
                theme = "dropdown",
                layout_strategy = "horizontal",
                layout_config = { width = 0.9, height = 0.99 },
                sorter = require("telescope.sorters").get_substr_matcher({}),
            },
            buffers = {
                sorter = require("telescope.sorters").get_fzy_sorter({}),
                use_regex = false,
                -- entry_maker = Custom.make_entry_file,
                theme = "dropdown",
                layout_config = { width = 0.8, height = 0.8 },
                previewer = false,
                mappings = {
                    n = {
                        ["d"] = actions.delete_buffer,
                    },
                },
                entry_maker = Custom.make_entry_buffers,
            },
        },
    })

    local grep_this_buffer = function()
        tb.live_grep({
            search_dirs = { vim.fn.expand("%:p") },
            -- word_march = "-w",
            fuzzy = false,
            use_regex = false,
            search = "",
            entry_maker = Custom.make_entry_line_content,
        })
    end

    vim.api.nvim_create_autocmd("User", {
        pattern = "TelescopePreviewerLoaded",
        callback = function(_)
            vim.wo.number = true
            vim.wo.wrap = true
        end,
    })

    telescope.load_extension("fzf")

    vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Fuzzy find files in cwd" })
    vim.keymap.set("n", "<leader>fs", tb.live_grep, { desc = "Find string in cwd" })
    vim.keymap.set("n", "<leader>fh", tb.buffers, { desc = "Find open buffers" })
    vim.keymap.set("n", "<leader>fb", tb.treesitter, { desc = "treesitter" })
    vim.keymap.set("n", "<leader>r", tb.resume, { desc = "resume" })
    vim.keymap.set("n", "<leader>_", grep_this_buffer, { desc = "word search" })
    vim.keymap.set("n", "<leader>/", grep_this_buffer, { desc = "word search" })
    vim.keymap.set("n", "<leader>fp", tb.pickers, { desc = "show all pickers" })
    vim.keymap.set("n", "<leader>fd", tb.diagnostics, { desc = "show all lsp diagnotics" })
    vim.keymap.set("n", "<leader>gc", tb.git_bcommits, { desc = "show all lsp diagnotics" })
    vim.keymap.set("n", "<leader>gC", tb.git_commits, { desc = "show all lsp diagnotics" })
    vim.keymap.set("n", "<leader>gs", tb.git_status, { desc = "show all lsp diagnotics" })
end

function Custom.make_entry_buffers(tbl)
    local entry = tbl.info
    -- entry = Custom.make_entry.gen_from_buffer({})(tbl)
    -- print(vim.inspect(tbl))


    local name = vim.fn.fnamemodify(entry.name, ":.")
    local icon, hl_group = Custom.utils.get_devicons(entry.name)
    local icon_width = Custom.strings.strdisplaywidth(icon)

    return Custom.make_entry.set_default_entry_mt({
        value = entry,
        ordinal = entry.name,
        bufnr = entry.bufnr,
        filename = entry.name,
        lnum = entry.lnum,
        col = entry.col,
        text = entry.text,
        start = entry.start,
        finish = entry.finish,
        display = function()
            return Custom.entry_display.create({
                separator = " ",
                items = {
                    { width = 4 },
                    { width = icon_width },
                    { remaining = true },
                },
            })({
                -- { string.format("[%d:%d]", entry.lnum, entry.col), "TelescopeResultsNumber" },
                {tostring(entry.bufnr), "TelescopeResultsNumber"},
                { icon, hl_group },
                { string.format("%s:%d", name, entry.lnum) },
            })
        end,
    }, entry)
end

function Custom.make_entry_line_content(entry)
    entry = Custom.make_entry.gen_from_vimgrep({})(entry)
    if not entry then
        return nil
    end
    return Custom.make_entry.set_default_entry_mt({
        value = entry,
        ordinal = entry.filename .. " " .. entry.text,
        bufnr = entry.bufnr,
        filename = entry.filename,
        lnum = entry.lnum,
        col = entry.col,
        text = entry.text,
        start = entry.start,
        finish = entry.finish,
        display = function(_entry)
            return Custom.entry_display.create({
                separator = " ",
                items = {
                    { remaining = true },
                    { remaining = true },
                },
            })({
                { string.format("[%d:%d]", _entry.lnum, _entry.col), "TelescopeResultsNumber" },
                { _entry.text },
            })
        end,
    }, entry)
end

function Custom.make_entry_text(entry)
    entry = entry or {}
    local show_line = vim.F.if_nil(entry.show_line, true)

    local filename = entry.filename
    if string.match(filename, "^[a-zA-Z][a-zA-Z0-9+.-]*://") ~= nil then
        filename = vim.uri_to_fname(filename)
    end
    local relpath = vim.fn.fnamemodify(filename, ":.")
    entry.filename = relpath

    local utils = Custom.utils
    local strings = Custom.strings

    local icon, hl_group = utils.get_devicons(relpath)
    local icon_width = strings.strdisplaywidth(icon)
    local entry_display = Custom.entry_display

    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = icon_width },
            { remaining = true },
            { width = 2 },
            { remaining = true },
        },
    })

    local make_display = function(_entry)
        return displayer({
            { icon, hl_group },
            { string.format("%s [%d:%d]", relpath, _entry.lnum, _entry.col) },
            { "->", "TelescopeResultsNumber" },
            { vim.trim(_entry.text) },
        })
    end

    return Custom.make_entry.set_default_entry_mt({
        value = entry,
        ordinal = filename .. " " .. entry.text,
        display = make_display,

        bufnr = entry.bufnr,
        filename = filename,
        lnum = entry.lnum,
        col = entry.col,
        text = entry.text,
        start = entry.start,
        finish = entry.finish,
    }, entry)
end

return {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Telescope",
    keys = {
        { "<leader>ff" },
        { "<leader>fs" },
        { "<leader>fb" },
        { "<leader>fg" },
        { "<leader>r" },
        { "<leader>fh" },
        { "<leader>fp" },
        { "<leader>fd" },
        { "<leader>gc" },
        { "<leader>gC" },
        { "<leader>gs" },
        { "<leader>/" },
        { "<leader>_" },
    },
    config = Custom.config,
}
