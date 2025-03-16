return {
	{
		"voldikss/vim-floaterm",
		config = function()
			-- vim.keymap.set("n", "<leader>tt", "<Cmd>FloatermToggle! cd %:p:h<CR>", { desc = "[T]oggle [T]erminal" })
			vim.keymap.set("n", "<leader>tt", function()
				vim.cmd("FloatermToggle!")
			end, { desc = "[T]oggle [T]erminal" })
			vim.keymap.set(
				"n",
				"<leader>T",
				"<Cmd>FloatermNew --width=0.9 --height=0.9 --cwd=<buffer><CR>",
				{ desc = "[T]erminal" }
			)
			-- vim.keymap.set("n", "<leader>tn", "<Cmd>FloatermNew --width=0.9 --height=0.9 --cwd=<buffer><CR>", { desc = "[N]ew floaterm" })
			vim.keymap.set("n", "<leader>tn", "<Cmd>FloatermNext<CR>", { desc = "[N]ext floaterm" })
			vim.keymap.set("n", "<leader>tp", "<Cmd>FloatermPrev<CR>", { desc = "[P]revious floaterm" })
			vim.keymap.set("n", "<leader>gg", function()
				vim.cmd("lcd %:p:h")
				vim.cmd("FloatermNew --autoclose=1 --width=0.9 --height=0.9 lazygit")
			end, { desc = "[G]it [G]ud" })
			-- vim.keymap.set(
			-- 	"n",
			-- 	"<leader>fr",
			-- 	"<Cmd>FloatermNew --height=0.6 --width=0.4 --wintype=float --name=floaterm1 --position=topleft --autoclose=2 ranger --cmd='cd ~'<CR>",
			-- 	{ desc = "Ranger" }
			-- )
		end,
	},
}
