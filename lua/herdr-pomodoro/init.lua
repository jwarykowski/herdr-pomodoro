-- herdr-pomodoro for Neovim: the timer as a statusline component. It reads
-- the plugin's state file (see the README); no herdr call.
local M = {}

local defaults = {
	icons = { work = "🍅", ["break"] = "☕", idle = "⏸" },
}

local config = vim.tbl_deep_extend("force", {}, defaults)

-- format renders a state for a statusline: "🍅 12:34" while a phase runs, the
-- idle icon between rounds (phase ""), else "".
local function format(state, now, icons)
	if type(state) ~= "table" then
		return ""
	end
	if state.phase ~= "work" and state.phase ~= "break" then
		return icons.idle or ""
	end
	local icon = icons[state.phase]
	if not icon or type(state.ends_at) ~= "number" then
		return ""
	end
	local left = math.max(0, state.ends_at - now)
	return ("%s %d:%02d"):format(icon, math.floor(left / 60), left % 60)
end

-- path is the state file bin/pomodoro writes
local function path()
	return (vim.env.XDG_STATE_HOME or (vim.env.HOME .. "/.local/state")) .. "/herdr-pomodoro/state.json"
end

-- the state file is re-read at most once a second, however often the
-- statusline redraws
local cache = { at = -1, state = nil }

local function read(now)
	if cache.at ~= now then
		cache.at = now
		cache.state = nil
		local f = io.open(path(), "r")
		if f then
			local ok, data = pcall(vim.json.decode, f:read("*a"))
			f:close()
			cache.state = ok and data or nil
		end
	end
	return cache.state
end

-- status returns the timer for a statusline, or "" when none runs.
function M.status()
	local now = os.time()
	return format(read(now), now, config.icons)
end

-- state returns the decoded state file (phase, started_at, ends_at, round, long), or
-- nil without a timer, for statuslines that render it themselves.
function M.state()
	return read(os.time())
end

function M.setup(opts)
	config = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

-- _internal exposes pure helpers for the test suite; not part of the public API.
M._internal = { format = format }

return M
