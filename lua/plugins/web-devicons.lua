return {
    "nvim-tree/nvim-web-devicons",
    config = function()
        local colors = require("ykm22.theme")
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
