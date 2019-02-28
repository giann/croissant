<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/logo.png" alt="croissant" width="304" height="304">
</p>

# Croissant
🥐 A Lua REPL and debugger implemented in Lua

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/croissant.gif" alt="croissant">
</p>

**Note:** Croissant is in active development.

Croissant is based on [sirocco](https://github.com/giann/sirocco).

## Features

- Syntax highlighting
- Code parsed as you type
- Persistent history
- Multiline
- Formatted returned values
- Basic auto-completion
- Contextual help (`C-h` or `M-h` on an identifier)
- Debugger

### Planned

- Customization: keybinding, theme, etc.
- Multiple Lua versions support

## Installation

Requirements:
- Lua 5.3
- luarocks >= 3.0 (_Note: `hererocks -rlatest` will install 2.4, you need to specify it with `-r3.0`_)

```bash
luarocks install croissant
```

## Usage

```bash
# Make sure lua/luarocks binaries are in your $PATH (~/.luarocks/bin)
croissant [-h] [<input>] [<arguments>] [-d [<debugger>] ...]
```

- `<input>`: a lua file to run or debug. If not provided, croissant will run the REPL.
- `<arguments>`: arguments to pass to the `<input>` script
- `--debugger -d --break -b [file.lua:line] ...`: runs croissant in debugger mode and optionally sets breakpoints
- `--help -h`: shows help message

## Debugger

### Using the cli

```bash
croissant filetodebug.lua -d
```

This will start croissant in debugger mode. You can then add some breakpoints with the `breakpoint` command and start your script with the `run` command.

### In your code

Alternatively, you can require the debugger in your script where you want to break:

```bash
require "croissant.debugger"()
```

### Commands

Croissant looks at the first word of your entry and runs any command it matches. It'll otherwise runs the entry as Lua code in the current frame context. If empty, croissant executes the previous repeatable command.

- **`run`**: starts your script
- **`args`**: set arguments to pass to your script
- **`breakpoint <file> <line>`**: add a new breakpoint in `file` at `line`
- **`delete <#id>`**: delete breakpoint `#id`
- **`enable <#id>`**: enable breakpoint `#id`
- **`disable <#id>`**: disable breakpoint `#id`
- **`clear`**: delete breakpoints
- **`info <what>`**:
    + `breakpoints`: list breakpoints
    + `locals`: list locals of the current frame
- **`step`** (repeatable): step in the code
- **`next`** (repeatable): step in the code but doesn't enter deeper context
- **`out`** (repeatable): will break after leaving the current frame
- **`up`** (repeatable): go up one frame
- **`down`** (repeatable): go down one frame
- **`continue`** (repeatable): continue until hitting a breakpoint. If no breakpoint are specified, clears debug hooks
- **`eval <code>`**: runs `code` (useful to disambiguate from debugger commands)
- **`exit`**: quit
- **`where`**: shows code around the current line. Is run for you each time you step in the code or change frame context.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/debugger/assets/debugger-where.png" alt="where command">
</p>

- **`trace`**: shows current stack trace and highlight current frame.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/debugger/assets/debugger-trace.png" alt="where trace">
</p>

You can truncate commands any way you want. If the truncated command is ambiguous, croissant will choose matching commands in this order:
- `breakpoint`
- `continue`
- `down`
- `delete`
- `disable`
- `eval`
- `enable`
- `exit`
- `info`
- `next`
- `out`
- `step`
- `run`
- `trace`
- `up`
- `where`
