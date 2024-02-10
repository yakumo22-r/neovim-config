return {
	"stevearc/conform.nvim",
	event = "VeryLazy",
	config = function()
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				c = { "clang_format" },
				lua = { "stylua" },
			},
		})
		local opt = { noremap = true, silent = true }
		vim.keymap.set({ "n", "v" }, "=", "", {
			noremap = true,
			silent = true,
			callback = function()
				require("conform").format({
					async = true,
					lsp_fallback = true,
				})
			end,
		})
	end,
}
