local bufferline = {}

-- Function to delete the current buffer
local function delete_current_buffer(force)
    -- Check if the buffer has unsaved changes
    if not force and vim.bo.modified then
        -- Prompt the user to save changes or force delete
        print("Buffer has unsaved changes. Use :w to save or :q! to force delete.")
        return
    end

    close_curr_buffer()
end

-- Function to save and delete the current buffer
local function save_and_delete_current_buffer()
    -- Save the current buffer
    vim.cmd('w')
    -- Delete the current buffer
    delete_current_buffer(false)
end

-- Create custom commands with uppercase names
vim.api.nvim_create_user_command('QuitBuffer', function() delete_current_buffer(false) end, {})
vim.api.nvim_create_user_command('QuitBufferForce', function() delete_current_buffer(true) end, {})
vim.api.nvim_create_user_command('WriteQuitBuffer', save_and_delete_current_buffer, {})

-- Remap :q, :q!, and :wq commands to custom commands
vim.cmd([[
  cnoreabbrev x QuitBuffer 
  cnoreabbrev x! QuitBufferForce
  cnoreabbrev xx WriteQuitBuffer
]])

local function next_cycle()
    local n = math.max(vim.v.count, 1)
    for i=1,n do
        vim.cmd("BufferLineCycleNext")
    end
end

local function prev_cycle()
    local n = math.max(vim.v.count, 1)
    for i=1,n do
        vim.cmd("BufferLineCyclePrev")
    end
end


return {
    "akinsho/bufferline.nvim",
    dependencies = "nvim-tree/nvim-web-devicons",
    version = "*",
    config = function()
        bufferline = require("bufferline")
        bufferline.setup({
            options = {
                separator_style = "slant",
            },
        })
        local opt = { noremap = true, silent = true }
        vim.keymap.set("n", "H", prev_cycle, opt)
        vim.keymap.set("n", "L", next_cycle, opt)
        vim.keymap.set("n", "<bs>c", close_curr_buffer, opt)
        vim.keymap.set("n", "<bs>o", ":BufferLineCloseOthers<CR>", opt)
        vim.keymap.set("n", "<bs>r", ":BufferLineCloseRight<CR>", opt)
        vim.keymap.set("n", "<bs>l", ":BufferLineCloseLeft<CR>", opt)

        vim.keymap.set("n", "<leader>bg", ":BufferLinePick<CR>", opt)
        vim.keymap.set("n", "<leader>bq", ":BufferLinePickClose<CR>", opt)
    end,
}
