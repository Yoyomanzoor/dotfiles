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
				view_df = {
					open_app = "tmux new-window vd", -- How to open the CSV
					how = "vsplit", -- How to display the data if doing it within Neovim
					csv_sep = "\t", -- Field separator to be used when saving the CSV.
					n_lines = -1, -- Number of lines to save in the CSV (0 for all lines).
					save_fun = "", -- R function to save the data.frame in a CSV file
					open_fun = "", -- R function to open the data.frame directly
					-- (no conversion to CSV needed)
				},
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
