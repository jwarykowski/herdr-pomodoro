local format = require("herdr-pomodoro")._internal.format

describe("format", function()
	local icons = { work = "W", ["break"] = "B", idle = "I" }

	it("shows the phase and the time left", function()
		assert.equals("W 12:05", format({ phase = "work", ends_at = 1725 }, 1000, icons))
		assert.equals("B 0:30", format({ phase = "long_break", ends_at = 1030 }, 1000, icons))
	end)

	it("stops at zero, shows idle, and is empty without a timer", function()
		assert.equals("W 0:00", format({ phase = "work", ends_at = 900 }, 1000, icons))
		assert.equals("I", format({ phase = "idle", ends_at = vim.NIL }, 1000, icons))
		assert.equals("", format(nil, 1000, icons))
	end)
end)
