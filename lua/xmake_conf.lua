-- TODO xmake project configuration
function foo()
    print("You chose Option 1")
end

function bar()
    print("You chose Option 2")
end

-- 创建一个浮动窗口并显示一个选择列表
function create_floating_window()
    local buf = vim.api.nvim_create_buf(false, true)
    local width = 20
    local height = 5
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        col = (vim.o.columns - width) / 2,
        row = (vim.o.lines - height) / 2,
    })

    -- 设置缓冲区内容为你的选择列表
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Option 1", "Option 2" })

    -- 设置键盘映射，当用户选择一个选项后，关闭窗口并执行相关的函数
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua select_option()<CR>", { noremap = true, silent = true })

    -- 定义选择选项的函数
    function select_option()
        local line = vim.api.nvim_win_get_cursor(win)[1]
        vim.api.nvim_win_close(win, true)
        if line == 1 then
            foo()
        elseif line == 2 then
            bar()
        end
    end
end
