-- Function to ensure Ghostty is running and has only one tab
local function ensureGhosttyAndRunScript()
	local appBundleID = "com.mitchellh.ghostty"
	local scriptPath = "/Users/jarrod.folino/Code/_cuiwork/me"

	-- Launch or focus Ghostty
	local app = hs.application.get(appBundleID)
	if not app then
		hs.alert.show("Launching Ghostty...")
		hs.application.launchOrFocusByBundleID(appBundleID)
		hs.timer.usleep(1000000) -- Wait 1 second for Ghostty to launch
	else
		app:activate()
	end
end

-- Bind the function to ctrl+opt+j
hs.hotkey.bind({ "ctrl", "alt" }, "j", ensureGhosttyAndRunScript)
