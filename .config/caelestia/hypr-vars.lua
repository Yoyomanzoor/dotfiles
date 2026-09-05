local function valid_keybind(key)
	return type(key) == "string" and key:match("%S") ~= nil
end

local function flatten_keybinds(keybinds, keys)
	keys = keys or {}

	if type(keybinds) == "table" then
		for _, keybind in pairs(keybinds) do
			flatten_keybinds(keybind, keys)
		end
	elseif valid_keybind(keybinds) then
		keys[#keys + 1] = keybinds
	end

	return keys
end

local function create_bind(keybinds, action, flags)
	local get_flags = type(flags) == "function" and flags or function()
		return flags
	end

	for _, key in ipairs(flatten_keybinds(keybinds)) do
		hl.bind(key, action, get_flags(key))
	end
end
for _, dir in ipairs({ "left", "right", "up", "down" }) do
	create_bind("SUPER + " .. dir, hl.dsp.focus({ direction = dir }))
	create_bind("SUPER + SHIFT + " .. dir, hl.dsp.window.move({ direction = dir }))
end

local key_map = {
	left = "h",
	right = "l",
	up = "k",
	down = "j",
}
for dir, key in pairs(key_map) do
	create_bind("SUPER + " .. key, hl.dsp.focus({ direction = dir }))
	create_bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

return {
	terminal = "kitty",
	kbCloseWindow = "SUPER + SHIFT + Q",
	kbLock = "SUPER + ALT + L",
	kbShowPanels = "SUPER + ALT + K",
	kbTerminal = "SUPER + Return",
	kbMoveWinToWsNext = {
		"SUPER + ALT + mouse_down",
		"SUPER + ALT + Page_Down",
		"CTRL + SUPER + SHIFT + Right",
		"CTRL + SUPER + SHIFT + L",
	},
	kbMoveWinToWsPrev = {
		"SUPER + ALT + mouse_up",
		"SUPER + ALT + Page_Up",
		"CTRL + SUPER + SHIFT + Left",
		"CTRL + SUPER + SHIFT + H",
	},
	kbNextWs = { "SUPER + mouse_down", "CTRL + SUPER + Right", "CTRL + SUPER + L", "SUPER + Page_Down" },
	kbPrevWs = { "SUPER + mouse_up", "CTRL + SUPER + Left", "CTRL + SUPER + H", "SUPER + Page_Up" },
}
