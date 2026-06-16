return {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    config = function()
        require("minuet").setup({
            provider = "openai_fim_compatible",
            request_timeout = 3,
            curl_cmd = "C:\\Windows\\System32\\curl.exe",
            throttle = 1500,
            debounce = 600,
            cmp = {
                enable_auto_complete = true,
            },
            virtualtext = {
                auto_trigger_ft = { "*" },
                keymap = {
                    accept = "<C-a>",
                    next = "<C-d>",
                    prev = "<C-u>",
                },
            },
            provider_options = {
                openai_fim_compatible = {
                    api_key = "DEEPSEEK_API_KEY",
                    name = "Deepseek",
                    end_point = "https://api.deepseek.com/beta/completions",
                    model = "deepseek-v4-flash",
                    optional = {
                        max_tokens = 256,
                        top_p = 0.9,
                    },
                },
            },
        })

        vim.keymap.set("n", "<leader>co", "<cmd>Minuet virtualtext toggle<cr>")
    end,
}
