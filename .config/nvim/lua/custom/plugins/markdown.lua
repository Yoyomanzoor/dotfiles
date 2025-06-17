return {
	{
		"tadmccorkle/markdown.nvim",
		ft = "markdown", -- or 'event = "VeryLazy"'
		opts = {
			-- configuration here or empty for defaults
		},
	},
	{
		"kiran94/edit-markdown-table.nvim",
		config = true,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		cmd = "EditMarkdownTable",
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		ft = { "markdown" },
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {},
	},
	-- {
	-- 	"snrogers/mermaider.nvim",
	-- 	lazy = false,
	-- 	dependencies = {
	-- 		"3rd/image.nvim", -- Required for image display
	-- 	},
	-- 	config = function()
	-- 		require("mermaider").setup({
	-- 			-- Command to run the mermaid-cli
	-- 			-- {{IN_FILE}} will be replaced with the input file path
	-- 			-- {{OUT_FILE}} will be replaced with the output file path
	-- 			mermaider_cmd = "npx -y -p @mermaid-js/mermaid-cli mmdc -i {{IN_FILE}} -o {{OUT_FILE}}.png -s 3",

	-- 			-- Directory for temporary files
	-- 			temp_dir = vim.fn.expand("/tmp/mermaider"),

	-- 			-- Auto render settings
	-- 			auto_render = true, -- Auto render on save
	-- 			auto_render_on_open = true, -- Auto render when opening a file
	-- 			auto_preview = true, -- Automatically preview after rendering

	-- 			-- Mermaid diagram styling
	-- 			theme = "forest", -- "dark", "light", "forest", "neutral"
	-- 			background_color = "#1e1e2e", -- Background color for diagrams

	-- 			-- Additional mmdc options
	-- 			mmdc_options = "",

	-- 			-- Window size settings
	-- 			max_width_window_percentage = 80, -- Maximum width as percentage of window
	-- 			max_height_window_percentage = 80, -- Maximum height as percentage of window

	-- 			-- Render settings
	-- 			inline_render = false, -- Use inline rendering instead of split window

	-- 			-- Split window settings (used when inline_render is false)
	-- 			use_split = true, -- Use a split window to show diagram
	-- 			split_direction = "vertical", -- "vertical" or "horizontal"
	-- 			split_width = 50, -- Width of the split (if vertical)
	-- 		})
	-- 	end,
	-- 	ft = { "mmd", "mermaid" },
	-- },
}
