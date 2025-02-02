-- http://lua-users.org/wiki/FileInputOutput
-- see if the file exists
local function file_exists(file)
	local f = io.open(file, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
	if not file_exists(file) then
		return {}
	end
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end
	return lines
end

-- tests the functions above
local file = vim.fn.expand("~/.config/gtk-3.0/settings.ini")
local lines = lines_from(file)

-- print all line numbers and their contents
local function themeswitcher(day_theme, night_theme)
	for k, v in pairs(lines) do
		if string.find(v, "gtk%-application%-prefer%-dark%-theme") then
			-- print(v)
			for s, l in string.gmatch(v, "(%w+)=(%w+)") do
				if l == "1" then
					vim.cmd("colorscheme " .. day_theme)
				else
					vim.cmd("colorscheme " .. night_theme)
				end
			end
		end
	end
end

return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		config = function()
			themeswitcher("catppuccin-latte", "catppuccin-mocha")
		end,
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
		lazy = false,
		config = function()
			require("nightfox")
			if os.getenv("HYPRLAND_INSTANCE_SIGNATURE") == nil then -- check if Hyprland is running
				vim.cmd("colorscheme elflord")
				-- else
				-- 	themeswitcher("dayfox", "rose-pine-main")
			end
		end,
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
	{ "nyoom-engineering/oxocarbon.nvim" },
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
