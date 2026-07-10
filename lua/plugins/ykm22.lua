return {
    {
        "yakumo22-r/nvim-ykm22-ui",
        name = "nvim_ykm22_ui",
        lazy = false,
    },
    {
        "yakumo22-r/nvim-ykm22-sftp",
        name = "nvim_ykm22_sftp",
        lazy = false,
        dependencies = {
            "yakumo22-r/nvim-ykm22-ui",
        },
    },
}
