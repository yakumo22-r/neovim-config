return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        local colors = ykm22_cols
        require("nvim-web-devicons").setup({
            override_by_extension = {
                ["lua.txt"] = {
                    icon = "󰢱",
                    color = colors.bright_blue,
                    name = "lua",
                },
            },
        })
    end,
}
