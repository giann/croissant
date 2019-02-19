
package = "croissant"
version = "0.0.1-2"
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
        ["croissant"]           = "croissant/init.lua",
        ["croissant.luaprompt"] = "croissant/luaprompt.lua",
        ["croissant.lexer"]     = "croissant/lexer.lua"
    },
    type = "builtin",
}

dependencies = {
    "lua >= 5.3",
    "sirocco >= 0.0.1-2",
    "hump >= 0.4-2",
    "lpeg >= 1.0.1-1",
}
