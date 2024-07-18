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

## Installation

Requirements:
- Lua 5.1/JIT/5.2/5.3 (needs more testing for < 5.3 though)
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
- **`watch <expression>`**: breaks when evaluated Lua `expression` changes value
- **`breakpoint <where> [<when>]`**: add a new breakpoint at `<where>` (can be line number in current file, `file.lua:line` or a function name) if `<when>` (lua code evaluated in the breakpoint context) is true or absent
- **`condition <#id> <when>`**: change breaking condition of breakpoint `#id`
- **`delete <#id>`**: delete breakpoint or watchpoint `#id`
- **`enable <#id>`**: enable breakpoint or watchpoint `#id`
- **`disable <#id>`**: disable breakpoint or watchpoint `#id`
- **`display <expression>`**: display evalued Lua `expression` each time the program stops
- **`undisplay <#id>`**: dlete display `#id`
- **`clear`**: deletes all breakpoints, watchpoints and displays
- **`info <what>`**:
    + `breakpoints`: list breakpoints and watchpoints
    + `locals`: list locals of the current frame
    + `displays`: list displays
- **`step`** (repeatable): step in the code
- **`next`** (repeatable): step in the code going over any function call
- **`finish`** (repeatable): will break after leaving the current function
- **`up`** (repeatable): go up one frame
- **`down`** (repeatable): go down one frame
- **`continue`** (repeatable): continue until hitting a breakpoint. If no breakpoint are specified, clears debug hooks
- **`eval <code>`**: runs `code` (useful to disambiguate from debugger commands)
- **`depth <depthLimit> <itemsLimit>`**: set depth limit and number of items when pretty printing values
- **`exit`**: quit
- **`where [<rows>]`**: prints `<rows>` or `conf.whereRows` rows around the current line. Is ran for you each time you step in the code or change frame context

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/debugger-where.png" alt="where command">
</p>

- **`trace`**: prints current stack trace and highlights current frame.

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/debugger-trace.png" alt="where trace">
</p>

## Caveats

- Pretty printing values can be expensive in CPU and memory: avoid dumping either large of deeply nested tables. You can play with the `dump.depthLimit` and `dump.itemsLimit` value in your `$XDG_CONFIG_HOME/croissantrc` or `~/.croissantrc`, or the `depth` command to avoid exploring to far down in complex tables.
- The debugger will slow your program down. Croissant will try and clear hooks whenever possible but if you know you won't hit anymore breakpoints, do a `clear` before doing `continue`.
- A breakpoint on a function name will not work if the function is not called by its name in your code. Example:

```lua
local function stopMe()
    -- ...
end

local function call(fn)
    fn()
end

call(stopMe)
```

## Configuration

You can customize some aspect of croissant by writing a `$XDG_CONFIG_HOME/croissantrc` or `~/.croissantrc` lua file. Here are the default values than you can overwrite:

```lua
return {
    -- Default prompt
    prompt = "→ ",
    -- Prompt used when editing multiple lines of code
    continuationPrompt = ".... ",

    -- Maximum amount of remembered lines
    -- Croissant manages two history file: one for the repl ($XDG_STATE_HOME/croissant_history),
    -- one for the debugger ($XDG_STATE_HOME/croissant_debugger_history)
    historyLimit = 1000,

    -- How many rows `where` should print around the current line
    whereRows = 4,

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

    dump = {
        -- Nesting limit at which croissant will stop when pretty printing a table
        depthLimit = 5,
        -- If a table has more items than itemsLimit, will stop there and print ellipsis
        itemsLimit = 30
    }
}
```

## Löve 2D

Read and understand the [**Caveats**](#caveats) section.

```bash
luarocks install croissant --tree mygame/lua_modules
```

Tell Löve to search in `lua_modules`:

```lua
love.filesystem.setRequirePath(
    love.filesystem.getRequirePath()
        .. ";lua_modules/share/lua/5.1/?/init.lua"
        .. ";lua_modules/share/lua/5.1/?.lua"
)

love.filesystem.setCRequirePath(
    love.filesystem.getCRequirePath()
    .. ";lua_modules/lib/lua/5.1/?.so"
)
```

Require `croissant.debugger` where you want to break:

```lua
require "croissant.debugger"()
```
