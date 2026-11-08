return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		-- config = function()
		-- 	themeswitcher("catppuccin-latte", "catppuccin-mocha")
		-- end,
	},
	{
		"EdenEast/nightfox.nvim",
		-- config = function()
		-- 	themeswitcher("dayfox", "carbonfox")
		-- end,
	},
	{
		"rose-pine/neovim",
		name = "rose-pine",
		-- lazy = false,
		-- config = function()
		-- 	require("nightfox")
		-- 	if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") == nil then -- check if Hyprland is running
		-- 		vim.cmd("colorscheme elflord")
		-- 		-- else
		-- 		-- 	themeswitcher("dayfox", "rose-pine-main")
		-- 	end
		-- end,
	},
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			-- Optionally configure and load the colorscheme
			-- directly inside the plugin declaration.
			vim.g.gruvbox_material_enable_italic = true
			-- vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		priority = 1000,
	},
	{
		"navarasu/onedark.nvim",
		-- config = function()
		-- 	require("onedark").load()
		-- end,
	},
	{
		"folke/tokyonight.nvim",
		priority = 1000,
		opts = {},
	},
	{
		"xero/miasma.nvim",
		priority = 1000,
	},
	{
		"comfysage/evergarden",
		priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
		opts = {
			transparent_background = true,
			variant = "medium", -- 'hard'|'medium'|'soft'
			overrides = {}, -- add custom overrides
		},
	},
	{
		"craftzdog/solarized-osaka.nvim",
		priority = 1000,
	},
	{ "marko-cerovac/material.nvim" },
	{ "projekt0n/github-nvim-theme", name = "github-theme" },
	{ "miikanissi/modus-themes.nvim", priority = 1000 },
	{ "Mofiqul/dracula.nvim" },
	{ "shaunsingh/nord.nvim" },
	{ "aliqyan-21/darkvoid.nvim" },
	{ "jackplus-xyz/binary.nvim" },
	{ "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000 },

	{
		"tingey21/telescope-colorscheme-persist.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		lazy = false,
		config = function()
			require("telescope-colorscheme-persist").setup({
				file_path = vim.fn.stdpath("cache")
					.. "/telescope-colorscheme-persist.nvim/.nvim.colorscheme-persist.lua",
				fallback = "default",
				picker_opts = require("telescope.themes").get_dropdown(),
				debug = false,
				keybind = "<leader>sc",
			})
		end,
	},
	{
		"lcroberts/persistent-colorscheme.nvim",
		lazy = false,
		priority = 1000, -- Plugin should be loaded early
		dependencies = {
			"RRethy/nvim-base16", -- Lots of baked-in themes and support to add more
		},
	},

	--[[ "f-person/auto-dark-mode.nvim",
	opts = {
		update_interval = 1000,
		set_dark_mode = function()
			-- vim.api.nvim_set_option_value("background", "dark", {})
			vim.cmd("colorscheme rose-pine-main")
		end,
		set_light_mode = function()
			-- vim.api.nvim_set_option_value("background", "light", {})
			vim.cmd("colorscheme rose-pine-dawn")
		end,
	}, ]]
}
