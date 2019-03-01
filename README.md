<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/logo.png" alt="croissant" width="304" height="304">
</p>

# Croissant
🥐 A Lua REPL and debugger implemented in Lua

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/repl.gif" alt="croissant">
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

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/debugger.gif" alt="croissant">
</p>

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

- **`help [<command>]`**: prints general help or help about specified command
- **`run`**: starts your script
- **`args <argument> ...`**: set arguments to pass to your script
- **`breakpoint <where> [<when>]`**: add a new breakpoint at `<where>` (can be line number in current file, `file.lua:line` or a function name) if `<when>` (lua code evaluated in the breakpoint context) is true or absent
- **`condition <#id> <when>`**: change breaking condition of breakpoint `#id`
- **`delete <#id>`**: delete breakpoint `#id`
- **`enable <#id>`**: enable breakpoint `#id`
- **`disable <#id>`**: disable breakpoint `#id`
- **`clear`**: delete breakpoints
- **`info <what>`**:
    + `breakpoints`: list breakpoints
    + `locals`: list locals of the current frame
- **`step`** (repeatable): step in the code
- **`next`** (repeatable): step in the code going over any function call
- **`out`** (repeatable): will break after leaving the current function
- **`up`** (repeatable): go up one frame
- **`down`** (repeatable): go down one frame
- **`continue`** (repeatable): continue until hitting a breakpoint. If no breakpoint are specified, clears debug hooks
- **`eval <code>`**: runs `code` (useful to disambiguate from debugger commands)
- **`exit`**: quit
- **`where`**: prints code around the current line. Is ran for you each time you step in the code or change frame context

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/debugger-where.png" alt="where command">
</p>

- **`trace`**: prints current stack trace and highlights current frame.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/debugger-trace.png" alt="where trace">
</p>

## Configuration

You can customize some aspect of croissant by writing a `~/.croissantrc` lua file. Here are the default values than you can overwrite:

```lua
return {
    -- Default prompt
    prompt = "→ ",
    -- Prompt used when editing multiple lines of code
    continuationPrompt = ".... ",

    -- Maximum amount of remembered lines
    -- Croissant manages two history file: one for the repl (~/.croissant_history),
    -- one for the debugger (~/.croissant_debugger_history)
    historyLimit = 1000,

    -- Syntax highlighting colors
    -- Available colors are: black, red, green, yellow, blue, magenta, cyan, white.
    -- They can also be combined with modifiers: bright, dim, underscore, blink, reverse, hidden
    syntaxColors = {
        constant   = { "bright", "yellow" },
        string     = { "green" },
        comment    = { "dim", "cyan" },
        number     = { "yellow" },
        operator   = { "yellow" },
        keywords   = { "bright", "magenta" },
        identifier = { "blue" },
    },

    -- Nesting limit at which croissant will stop when pretty printing a table
    dumpLimit = 5,
}
```
