local map = vim.keymap.set

return {
	map("n", ";", ":", { desc = "CMD enter command mode" }),

	-- Obsidian maps
	map("n", "<leader>ot", "<cmd>ObsidianTags<CR>", { desc = "[O]bsidian [T]ags" }),
	map("n", "<leader>on", "<cmd>ObsidianToday<CR>", { desc = "[O]bsidian today's [N]ote" }),
	map("n", "<leader>oc", "<cmd>ObsidianTOC<CR>", { desc = "[O]bsidian table of [C]ontents" }),
	map("n", "<leader>op", "<cmd>ObsidianPasteImg<CR>", { desc = "[O]bsidian [P]aste image" }),
}
