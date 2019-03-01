
package = "croissant"
version = "0.0.1-5"
rockspec_format = "3.0"

source = {
    url = "git://github.com/giann/croissant",
}

description = {
    summary  = "A Lua REPL implemented in Lua",
    homepage = "https://github.com/giann/croissant",
    license  = "MIT/X11",
}

build = {
    modules = {
        ["croissant.repl"]      = "croissant/repl.lua",
        ["croissant.conf"]      = "croissant/conf.lua",
        ["croissant.debugger"]  = "croissant/debugger.lua",
        ["croissant.do"]        = "croissant/do.lua",
        ["croissant.help"]      = "croissant/help.lua",
        ["croissant.lexer"]     = "croissant/lexer.lua",
        ["croissant.luaprompt"] = "croissant/luaprompt.lua",
        ["croissant.builtins"]  = "croissant/builtins.lua",
    },
    type = "builtin",
    install = {
        bin = {
            "bin/croissant"
        }
    }
}

dependencies = {
    "lua >= 5.3",
    "sirocco >= 0.0.1-4",
    "hump >= 0.4-2",
    "lpeg >= 1.0.1-1",
    "argparse >= 0.6.0-1"
}
