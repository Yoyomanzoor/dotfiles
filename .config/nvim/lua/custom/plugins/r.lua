return {
	{
		"R-nvim/R.nvim",
		-- Only required if you also set defaults.lazy = true
		lazy = false,
		config = function()
			require("r").setup({
				-- pipe_keymap = "",
				disable_cmds = { "RInsertPipe" },
				R_app = "radian",
			})
		end,
	},
	{
		"chrisbra/csv.vim",
	},
	-- {
	-- 	"R-nvim/cmp-r",
	-- 	{
	-- 		"hrsh7th/nvim-cmp",
	-- 		config = function()
	-- 			require("cmp").setup({ sources = { { name = "cmp_r" } } })
	-- 			require("cmp_r").setup({})
	-- 		end,
	-- 	},
	-- },
}
