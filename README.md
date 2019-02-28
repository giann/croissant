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
croissant [-h] [<input>] [-b [<break>] ...]
```

- `input`: A lua file to run or debug. If not provided, croissant will run the REPL.
- `--break -b [file.lua:line] ...`: Will break at given lines. If non provided, will break at first line of code.
- `--help -h`: Show help message.

## Debugger

Either use croissant to run your file and specify some breakpoints with `--break` or add this where you want to break in your code:

```bash
require "croissant.debugger"()
```

Croissant looks at the first word of your entry and runs any command it matches. Otherwise runs entry as Lua code in the current frame context.
If entry empty, executes previous commands.

- **`where`**: shows code around the current line. Is run for you each time you step in the code or change frame context.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/debugger/assets/debugger-where.png" alt="where command">
</p>

- **`trace`**: shows current stack trace and highlight current frame.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/debugger/assets/debugger-trace.png" alt="where trace">
</p>

- **`breakpoint <file> <line>`**: add a new breakpoint in `file` at `line`
- **`delete <#id>`**: delete breakpoint `#id`
- **`enable <#id>`**: enable breakpoint `#id`
- **`disable <#id>`**: disable breakpoint `#id`
- **`info <what>`**:
    + `breakpoints`: list breakpoints
- **`step`**: step in the code
- **`next`**: step in the code but doesn't enter deeper context
- **`out`**: will break after leaving the current frame
- **`up`**: go up one frame
- **`down`**: go down one frame
- **`continue`**: continue until hitting a breakpoint. If no breakpoint are specified, clears debug hooks

You can truncate the command any way you want. If the truncated command is ambiguous, croissant will choose from the matching commands in this order:
- `breakpoint`
- `continue`
- `down`
- `delete`
- `disable`
- `enable`
- `info`
- `next`
- `out`
- `step`
- `trace`
- `up`
- `where`
