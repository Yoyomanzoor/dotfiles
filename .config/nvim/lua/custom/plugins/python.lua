return {

	{
		"meatballs/notebook.nvim",
		config = function()
			require("notebook").setup({
				-- Whether to insert a blank line at the top of the notebook
				insert_blank_line = true,

				-- Whether to display the index number of a cell
				show_index = true,

				-- Whether to display the type of a cell
				show_cell_type = true,

				-- Style for the virtual text at the top of a cell
				virtual_text_style = { fg = "lightblue", italic = true },
			})
		end,
	},
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes

		build = ":UpdateRemotePlugins",
		init = function()
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- Windows Terminal: text in Neovim, plots in the Windows image viewer.
			vim.g.molten_image_provider = "none"
            vim.g.molten_open_cmd = "wsl-open"
            vim.g.molten_auto_image_popup = true
            vim.env.BROWSER = "wsl-open"

			-- optional, I like wrapping. works for virt text and the output window
			vim.g.molten_wrap_output = true

			-- Output as virtual text. Allows outputs to always be shown, works with images, but can
			-- be buggy with longer images
			-- vim.g.molten_virt_text_output = true

			-- this will make it so the output shows up below the \`\`\` cell delimiter
			vim.g.molten_virt_lines_off_by_1 = true

			vim.keymap.set("n", "<leader>mi", ":MoltenInit<CR>", { desc = "[M]olten [I]nit" })
			vim.keymap.set("n", "<leader>ml", ":MoltenEvaluateLine<CR>", { desc = "[M]olten [L]nit" })

			vim.keymap.set(
				"n",
				"<leader>me",
				":MoltenEvaluateOperator<CR>",
				{ desc = "[M]olten [E]valuate operator", silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>ms",
				":noautocmd MoltenEnterOutput<CR>",
				{ desc = "[M]olten open output window", silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>mr",
				":MoltenReevaluateCell<CR>",
				{ desc = "[M]olten [R]e-eval cell", silent = true }
			)
			vim.keymap.set(
				"v",
				"<leader>mv",
				":<C-u>MoltenEvaluateVisual<CR>gv",
				{ desc = "[M]olten execute [V]isual selection", silent = true }
			)
			vim.keymap.set(
				"n",
				"<leader>mq",
				":MoltenHideOutput<CR>",
				{ desc = "[M]olten close output window", silent = true }
			)
			vim.keymap.set("n", "<leader>md", ":MoltenDelete<CR>", { desc = "[M]olten [D]elete cell", silent = true })

			-- if you work with html outputs:
			vim.keymap.set(
				"n",
				"<leader>mx",
				":MoltenOpenInBrowser<CR>",
				{ desc = "[M]olten open output in browser", silent = true }
			)
		end,
	},
	{
		"GCBallesteros/jupytext.nvim",
		config = function()
			require("jupytext").setup({
				style = "markdown",
				output_extension = "md",
				force_ft = "markdown",
			})
		end,
	},
}
