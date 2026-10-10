.PHONY: fmt lint test check

fmt:
	stylua lua/ tests/

lint:
	shellcheck bin/pomodoro
	stylua --check lua/ tests/
	luacheck lua/ tests/

test:
	busted

check: lint test
