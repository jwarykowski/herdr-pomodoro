<p align="center"><img src="assets/herdr-pomodoro.svg" alt="herdr-pomodoro" width="120"></p>

# herdr-pomodoro

A [herdr](https://herdr.dev) plugin: a pomodoro timer with notifications, a
sidebar token and hooks. Its state is one JSON file, so anything can show it:
a Neovim statusline, keyboard lights, a shell prompt.

- 25 minutes of work, a 5 minute break, and a 15 minute break every fourth
  round (all configurable).
- A herdr notification when each phase ends.
- `$pomo` in the sidebar, e.g. `🍅12m`.
- Hooks: run your own commands when a round starts or ends.

## Requirements

- herdr 0.9.3+
- `jq`, `bash`

## Install

```sh
herdr plugin install jwarykowski/herdr-pomodoro
```

Bind the toggle in herdr's `config.toml`, and add `$pomo` to the sidebar if
you want it there:

```toml
[[keys.command]]
key = "prefix+p"
type = "plugin_action"
command = "jwarykowski.herdr-pomodoro.toggle"
description = "start / stop the pomodoro"

[ui.sidebar.spaces]
rows = [["state_icon", "workspace", "$pomo"], ["branch", "git_status"]]
```

## Actions

| action | does |
|---|---|
| `jwarykowski.herdr-pomodoro.toggle` | stop if running, else start |
| `jwarykowski.herdr-pomodoro.start` | start a work round (the next round after a break) |
| `jwarykowski.herdr-pomodoro.stop` | stop and reset the round count |
| `jwarykowski.herdr-pomodoro.skip` | end the current phase now |

When a break ends the timer waits for you to start the next round; set
`HERDR_POMODORO_AUTO_CONTINUE=1` to carry straight on.

## State file

`${XDG_STATE_HOME:-~/.local/state}/herdr-pomodoro/state.json`:

```json
{"phase": "work", "started_at": 1760160000, "ends_at": 1760161500, "round": 2}
```

`phase` is `work`, `break`, `long_break`, or `idle` (between rounds, `ends_at`
null). Times are unix seconds, so a reader works out the remaining time itself
and nothing has to tick. No file means no timer.

`bin/pomodoro status` prints one line for prompts and status bars
(`🍅 12:34`, `☕ 3:10`, `⏸`, or nothing).

## Neovim

The repo is also a Neovim plugin with a statusline component. With
[lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{ "jwarykowski/herdr-pomodoro", lazy = true }
```

`require("herdr-pomodoro").status()` returns `🍅 12:34`, `☕ 3:10`, `⏸` or `""`;
`.state()` returns the decoded state file for your own rendering. It reads the
file at most once a second, so it is cheap on every redraw. With lualine:

```lua
sections = {
	lualine_x = { function() return require("herdr-pomodoro").status() end, "filetype" },
},
```

Change the icons with
`require("herdr-pomodoro").setup({ icons = { work = "W", ["break"] = "B", idle = "-" } })`.

## Hooks

An executable in `$(herdr plugin config-dir jwarykowski.herdr-pomodoro)/hooks/`
named after an event runs when it happens:

| event | when |
|---|---|
| `pomodoro.started` | a work round starts |
| `pomodoro.work_done` | a work round ends, a break starts |
| `pomodoro.break_done` | a break ends |
| `pomodoro.stopped` | the timer is stopped |

Hooks get `HERDR_POMODORO_EVENT`, `_PHASE`, `_ROUND`, `_ENDS_AT` and `_STATE`
(the state file path), and log to `hooks.log` next to it. For example,
`hooks/pomodoro.work_done`:

```sh
#!/bin/sh
herdr plugin action invoke party --plugin jwarykowski.herdr-zsa-lights
```

## Configuration

Optional. Put overrides in `config.env` inside the plugin config directory;
see [`config.env.example`](config.env.example).

## Development

```sh
make lint    # shellcheck, stylua --check, luacheck
make test    # busted (specs run under Neovim via nlua)
```

## Support

herdr-pomodoro is free and MIT licensed. If it keeps you focused, you can
[sponsor its development](https://github.com/sponsors/jwarykowski).

## License

MIT
