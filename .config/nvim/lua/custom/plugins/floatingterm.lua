return {
	-- {
	-- 	"voldikss/vim-floaterm",
	-- 	config = function()
	-- 		-- vim.keymap.set("n", "<leader>tt", "<Cmd>FloatermToggle! cd %:p:h<CR>", { desc = "[T]oggle [T]erminal" })
	-- 		vim.keymap.set("n", "<leader>tt", function()
	-- 			vim.cmd("FloatermToggle!")
	-- 		end, { desc = "[T]oggle [T]erminal" })
	-- 		vim.keymap.set(
	-- 			"n",
	-- 			"<leader>T",
	-- 			"<Cmd>FloatermNew --width=0.9 --height=0.9 --cwd=<buffer><CR>",
	-- 			{ desc = "[T]erminal" }
	-- 		)
	-- 		-- vim.keymap.set("n", "<leader>tn", "<Cmd>FloatermNew --width=0.9 --height=0.9 --cwd=<buffer><CR>", { desc = "[N]ew floaterm" })
	-- 		vim.keymap.set("n", "<leader>tn", "<Cmd>FloatermNext<CR>", { desc = "[N]ext floaterm" })
	-- 		vim.keymap.set("n", "<leader>tp", "<Cmd>FloatermPrev<CR>", { desc = "[P]revious floaterm" })
	-- 		vim.keymap.set("n", "<leader>gg", function()
	-- 			vim.cmd("lcd %:p:h")
	-- 			vim.cmd("FloatermNew --autoclose=1 --width=0.9 --height=0.9 lazygit")
	-- 		end, { desc = "[G]it [G]ud" })
	-- 		-- vim.keymap.set(
	-- 		-- 	"n",
	-- 		-- 	"<leader>fr",
	-- 		-- 	"<Cmd>FloatermNew --height=0.6 --width=0.4 --wintype=float --name=floaterm1 --position=topleft --autoclose=2 ranger --cmd='cd ~'<CR>",
	-- 		-- 	{ desc = "Ranger" }
	-- 		-- )
	-- 	end,
	-- },
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				open_mapping = [[<leader>tt]],
				insert_mappings = false,
				terminal_mappings = false,
				direction = "vertical",
			})

			function _G.set_terminal_keymaps()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
				-- vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
				vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
				vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
				vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
				vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
				vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
			end

			-- if you only want these mappings for toggle term use term://*toggleterm#* instead
			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

			local trim_spaces = false
			vim.keymap.set("n", "<leader>tl", function()
				require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
			end, { desc = "[T]erminal send [L]ine" })
			vim.keymap.set("v", "<leader>tv", function()
				require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
			end, { desc = "[T]erminal send [V]isual" })

			-- For use as an operator map:
			-- Send motion to terminal
			-- vim.keymap.set("n", [[<leader><c-\>]], function()
			-- 	set_opfunc(function(motion_type)
			-- 		require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
			-- 	end)
			-- 	vim.api.nvim_feedkeys("g@", "n", false)
			-- end)
			-- Double the command to send line to terminal
			-- vim.keymap.set("n", [[<leader><c-\><c-\>]], function()
			-- 	set_opfunc(function(motion_type)
			-- 		require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
			-- 	end)
			-- 	vim.api.nvim_feedkeys("g@_", "n", false)
			-- end)
			-- Send whole file
			vim.keymap.set("n", [[<leader>tm]], function()
				set_opfunc(function(motion_type)
					require("toggleterm").send_lines_to_terminal(motion_type, false, { args = vim.v.count })
				end, { desc = "[T]erminal send [M]otion" })
				vim.api.nvim_feedkeys("ggg@G''", "n", false)
			end)

			local Terminal = require("toggleterm.terminal").Terminal
			local ipython = Terminal:new({
				cmd = "ipython --no-autoindent --matplotlib",
				display_name = "ipython",
				direction = "vertical",
				close_on_exit = true,
				on_open = function(term)
					vim.cmd("startinsert!")
				end,
			})
			function _ipython_toggle()
				ipython:toggle()
			end

			vim.api.nvim_set_keymap(
				"n",
				"<leader>tp",
				"<cmd>lua _ipython_toggle()<CR>",
				{ noremap = true, silent = true, desc = "[T]oggle [P]ython" }
			)

			local lazygit = Terminal:new({
				cmd = "lazygit",
				dir = "git_dir",
				direction = "float",
				float_opts = {
					border = "double",
				},
				-- function to run on opening the terminal
				on_open = function(term)
					vim.cmd("startinsert!")
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"n",
						"q",
						"<cmd>close<CR>",
						{ noremap = true, silent = true }
					)
				end,
				-- function to run on closing the terminal
				on_close = function(term)
					vim.cmd("startinsert!")
				end,
			})

			function _lazygit_toggle()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap(
				"n",
				"<leader>gg",
				"<cmd>lua _lazygit_toggle()<CR>",
				{ noremap = true, silent = true, desc = "[G]it [G]ud" }
			)
			local function markdown_codeblock(language, content)
				return "\\`\\`\\`{" .. language .. "}\n" .. content .. "\n\\`\\`\\`"
			end

			local quarto_notebook_cmd = 'nvim -c enew -c "set filetype=quarto"'
				.. ' -c "norm GO## IPython\nThis is Quarto IPython notebook. Syntax is the same as in markdown\n\n'
				.. markdown_codeblock("python", "# enter code here\n")
				.. '"'
				.. ' -c "norm Gkk"'
				-- This line needed because QuartoActivate and MoltenInit commands must be accessible; should be adjusted depending on plugin manager
				.. " -c \"lua require('lazy.core.loader').load({'molten-nvim', 'quarto-nvim'}, {cmd = 'Lazy load'})\""
				.. ' -c "MoltenInit python3" -c QuartoActivate -c startinsert'

			local molten_term = Terminal:new({
				cmd = quarto_notebook_cmd,
				hidden = true,
				direction = "float",
			})
			vim.keymap.set("n", "<C-p>", function()
				molten_term:toggle()
			end, { noremap = true, silent = true })
			vim.keymap.set("t", "<C-p>", function()
				vim.cmd("stopinsert")
				molten_term:toggle()
			end, { noremap = true, silent = true })
		end,
	},
}
