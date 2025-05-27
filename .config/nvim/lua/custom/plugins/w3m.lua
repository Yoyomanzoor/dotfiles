---@diagnostic disable: redefined-local
return {
	{
		"yuratomo/w3m.vim",
		event = "VeryLazy",
		config = function()
			-- vim.g["w3m#search_engine"] = "%s"
			vim.g["w3m#search_engine"] = "https://duckduckgo.com/?q=%s"
			vim.g["w3m#external_browser"] = "vieb"
			vim.keymap.set("n", "<leader>e", ":W3m ", { desc = "Search the web" })
			vim.keymap.set("n", "<leader>E", "<cmd>W3mAddressBar<CR>", { desc = "Open Address Bar" })
			vim.keymap.set("n", "<leader>wr", "<cmd>W3mReload<CR>", { desc = "[W]eb [R]eload" })
			vim.keymap.set("n", "<leader>wh", "<cmd>W3mHistory<CR>", { desc = "[W]eb [H]istory" })
			vim.keymap.set("n", "<leader>ws", ":W3mSplit ", { desc = "Search the web ([S]plit)" })
			vim.keymap.set("n", "<leader>wv", ":W3mVSplit ", { desc = "Search the web ([V]split)" })

			vim.keymap.set(
				"n",
				"<leader>we",
				vim.cmd("call w3m#ShowExternalBrowser()"),
				{ desc = "open in [E]xternal browser (vieb)" }
			)

			vim.keymap.set("n", "<leader>wy", function()
				vim.cmd("call w3m#ShowURL()")
				local status_msg = vim.v.statusmsg
				local url = status_msg:match("w3m:%s*(.+)")
				if url then
					vim.fn.setreg("+", url)
				else
					print("Failed to print url")
				end
			end, { desc = "[W]eb [Y]ank URL" })

			-- vim.keymap.set("n", "<leader>ww", function()
			-- 	local clipboard_content = vim.fn.getreg("+")
			-- 	if clipboard_content == "" then
			-- 		print("Clipboard is empty, copy a URL fragment first")
			-- 		return
			-- 	end
			-- 	local url = "http://" .. clipboard_content
			-- 	print(url)
			-- 	vim.cmd("W3m " .. url)
			-- end, { desc = "[W]eb search URL from clipboard" })

			vim.keymap.set("n", "<leader>wd", function()
				-- local word = vim.fn.expand("<cword>")
				-- word = word:match("^ *(.-) *$")
				vim.cmd("normal! vE")
				vim.cmd('normal! "+y')
				local word = vim.fn.getreg("+")
				if word == "" then
					print("No word undor cursor to search")
					return
				end
				vim.fn.setreg("+", word)
				local url = "http://" .. word
				print(url)
				vim.cmd("W3m " .. url)
			end, { desc = "[W]eb [D]uckduckgo search URL" })

			vim.keymap.set("n", "<leader>wm", function()
				vim.cmd("call w3m#ShowURL()")
				local url = vim.v.statusmsg:match("w3m:%s*(.+)")
				vim.cmd("call w3m#ShowTitle()")
				local title = vim.v.statusmsg:match("w3m:%s*(.+)")
				if not url or url == "" then
					print("Failed to retrieve the URL")
					return
				end
				if not title or title == "" then
					print("Failed to retrieve the title")
					return
				end

				local bookmarks_file = vim.fn.expand("~/.local/state/nvim/w3m")
				vim.fn.mkdir(vim.fn.fnamemodify(bookmarks_file, ":h"), "p")

				local function bookmark_exists(i_url)
					local file = io.open(bookmarks_file, "r")
					if not file then
						return false
					end
					for line in file:lines() do
						-- if line:match("url:%s*" .. i_url) then
						if line:match("url:%s*(.+)") == url then
							file:close()
							return true
						end
					end
					file:close()
					return false
				end
				if bookmark_exists(url) then
					print("Bookmark already exists")
					return
				end

				local entry = string.format("- title: %s\nurl: %s\n", title, url)
				local file = io.open(bookmarks_file, "a")
				if file then
					file:write(entry)
					file:close()
					print("Bookmark saved: " .. title .. " (" .. url .. ")")
				else
					print("Failed to open bookmarks file.")
				end
			end, { desc = "Save [W]eb Book[M]ark" })

			vim.keymap.set("n", '<leader>w"', function()
				local bookmarks_file = vim.fn.expand("~/.local/state/nvim/w3m")
				if vim.fn.filereadable(bookmarks_file) == 0 then
					print("bookmarks file not found.")
					return
				end
				local bookmarks = {}
				local current_title = nil
				for line in io.lines(bookmarks_file) do
					if line:match("^%s*%- title:") then
						current_title = line:match("^%s*%- title:%s*(.+)")
					elseif line:match("^%s*url:") and current_title then
						local url = line:match("^%s*url:%s*(.+)")
						if url then
							table.insert(bookmarks, string.format("%s (%s)", current_title, url))
							current_title = nil
						end
					end
				end
				if #bookmarks == 0 then
					print("No bookmarks found.")
					return
				end
				local fzf_input = table.concat(bookmarks, "\n")
				local selected = vim.fn.systemlist("echo '" .. fzf_input:gsub("'", "'\\''") .. "' | fzf")[1]
				vim.cmd("call fzf#run({ 'source': bookmarks, 'sink': 'W3m'})")

				if not selected or selected == "" then
					print("No bookmarks selected")
					return
				end
				local url = selected:match("%((https?://.-)%)")
				if not url then
					print("Failed to extract URL from selection")
					return
				end
				-- vim.cmd("W3m " .. url)
			end, { desc = "Load [W]eb Bookmark" })
		end,
	},
}
