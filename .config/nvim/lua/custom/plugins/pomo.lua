return {
	"epwalsh/pomo.nvim",
	version = "*", -- Recommended, use latest release instead of latest commit
	lazy = true,
	cmd = { "TimerStart", "TimerRepeat", "TimerSession" },
	dependencies = {
		-- Optional, but highly recommended if you want to use the "Default" timer
		"rcarriga/nvim-notify",
	},
	opts = {
		-- See below for full list of options 👇  -- How often the notifiers are updated.
		update_interval = 1000,

		-- Configure the default notifiers to use for each timer.
		-- You can also configure different notifiers for timers given specific names, see
		-- the 'timers' field below.
		notifiers = {
			-- The "Default" notifier uses 'vim.notify' and works best when you have 'nvim-notify' installed.
			{
				name = "Default",
				opts = {
					-- With 'nvim-notify', when 'sticky = true' you'll have a live timer pop-up
					-- continuously displayed. If you only want a pop-up notification when the timer starts
					-- and finishes, set this to false.
					sticky = true,

					-- Configure the display icons:
					title_icon = "󱎫",
					text_icon = "󰄉",
					-- Replace the above with these if you don't have a patched font:
					-- title_icon = "⏳",
					-- text_icon = "⏱️",
				},
			},

			-- You can also define custom notifiers by providing an "init" function instead of a name.
			-- See "Defining custom notifiers" below for an example 👇
			-- { init = function(timer) ... end }
		},

		-- You can optionally define custom timer sessions.
		sessions = {
			-- Example session configuration for a session called "pomodoro".
			pomodoro = {
				{ name = "Work", duration = "25m" },
				{ name = "Short Break", duration = "5m" },
				{ name = "Work", duration = "25m" },
				{ name = "Short Break", duration = "5m" },
				{ name = "Work", duration = "25m" },
				{ name = "Long Break", duration = "15m" },
			},
		},
	},
}
