<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/logo.png" alt="croissant" width="304" height="304">
</p>

# Croissant
🥐 A Lua REPL implemented in Lua

<p align="center">
    <img src="https://github.com/giann/croissant/raw/master/assets/croissant.gif" alt="croissant">
</p>

**Note:** Croissant is in active development.

## Installation

Requirements:
- Lua 5.3
- luarocks >= 3.0 (_Note: `hererocks -rlatest` will install 2.4, you need to specify it with `-r3.0`_)

```bash
luarocks install croissant
```

## Usage

```bash
lua -e "require 'croissant'()"
```

## Features

- Syntax highlighting
- Code interpreted as you type
- History
- Multiline
- Formatted returned values
- Basic auto-completion

## Todo

- Accurate auto-completion
- Customization: keybinding, theme, etc.
- Multiple Lua versions support
- Debugging https://github.com/slembcke/debugger.lua
