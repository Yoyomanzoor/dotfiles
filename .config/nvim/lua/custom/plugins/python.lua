return {
	{
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		dependencies = { "3rd/image.nvim" },
		build = ":UpdateRemotePlugins",
		init = function()
			-- I find auto open annoying, keep in mind setting this option will require setting
			-- a keybind for `:noautocmd MoltenEnterOutput` to open the output again
			vim.g.molten_auto_open_output = false

			-- this guide will be using image.nvim
			-- Don't forget to setup and install the plugin if you want to view image outputs
			vim.g.molten_image_provider = "image.nvim"

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
	-- {
	-- 	"quarto-dev/quarto-nvim",
	-- 	dependencies = {
	-- 		"jmbuhr/otter.nvim",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- 	config = function()
	-- 		local quarto = require("quarto")
	-- 		quarto.setup({
	-- 			lspFeatures = {
	-- 				-- NOTE: put whatever languages you want here:
	-- 				languages = { "r", "python", "rust" },
	-- 				chunks = "all",
	-- 				diagnostics = {
	-- 					enabled = true,
	-- 					triggers = { "BufWritePost" },
	-- 				},
	-- 				completion = {
	-- 					enabled = true,
	-- 				},
	-- 			},
	-- 			keymap = {
	-- 				-- NOTE: setup your own keymaps:
	-- 				hover = "H",
	-- 				definition = "gd",
	-- 				-- rename = "<leader>rn",
	-- 				references = "gr",
	-- 				format = "<leader>gf",
	-- 			},
	-- 			codeRunner = {
	-- 				enabled = true,
	-- 				default_method = "molten",
	-- 			},
	-- 		})
	-- 		local runner = require("quarto.runner")
	-- 		vim.keymap.set("n", "<leader>qc", runner.run_cell, { desc = "run cell", silent = true })
	-- 		vim.keymap.set("n", "<leader>qa", runner.run_above, { desc = "run cell and above", silent = true })
	-- 		vim.keymap.set("n", "<leader>qA", runner.run_all, { desc = "run all cells", silent = true })
	-- 		vim.keymap.set("n", "<leader>ql", runner.run_line, { desc = "run line", silent = true })
	-- 		vim.keymap.set("v", "<leader>q", runner.run_range, { desc = "run visual range", silent = true })
	-- 		vim.keymap.set("n", "<leader>RA", function()
	-- 			runner.run_all(true)
	-- 		end, { desc = "run all cells of all languages", silent = true })
	-- 	end,
	-- },
	{
		"3rd/image.nvim",
		config = function()
			require("image").setup({
				backend = "kitty", -- Kitty will provide the best experience, but you need a compatible terminal
				max_width = 100, -- tweak to preference
				max_height = 12, -- ^
				max_height_window_percentage = math.huge, -- this is necessary for a good experience
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true,
				processor = "magick_rock", -- or "magick_cli"
				integrations = {
					markdown = {
						enabled = false,
						clear_in_insert_mode = true,
						download_remote_images = true,
						only_render_image_at_cursor = true,
						floating_windows = false, -- if true, images will be rendered in floating markdown windows
						filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
					},
					neorg = {
						enabled = true,
						filetypes = { "norg" },
					},
					typst = {
						enabled = true,
						filetypes = { "typst" },
					},
					html = {
						enabled = false,
					},
					css = {
						enabled = false,
					},
				},
				window_overlap_clear_ft_ignore = {
					"cmp_menu",
					"cmp_docs",
					"snacks_notif",
					"scrollview",
					"scrollview_sign",
				},
				editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focus
				tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
				hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" }, -- render image files as images when opened
			})
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
