local colors = require "term.colors"
local char   = require "sirocco.char"

local merge
function merge(t1, t2, seen)
    seen = seen or {}
    local merged = {}

    seen[t1] = true
    seen[t2] = true

    for k, v in pairs(t1) do
        merged[k] = v
    end

    for k, v in pairs(t2) do
        if type(v) == "table" and not seen[v] then
            seen[v] = true

            if type(merged[k]) ~= "table" then
                merged[k] = {}
            end

            merged[k] = merge(merged[k], v, seen)
        else
            merged[k] = v
        end
    end

    return merged
end

local default = {
    -- TODO: unused
    keybinding = {
        command_get_next_history = {
            "key_down",
            "C-n",
        },

        command_get_previous_history = {
            "key_up",
            "C-p",
        },

        command_exit = {
            "C-c"
        },

        command_abort = {
            "C-g"
        },

        command_help = {
            "C- ",
            "M- ",
        },
    },

    prompt = "→ ",
    continuationPrompt = ".... ",

    historyLimit = 1000,

    whereRows = 4,

    syntaxColors = {
        constant   = { "bright", "yellow" },
        string     = { "green" },
        comment    = { "dim", "cyan" },
        number     = { "yellow" },
        operator   = { "yellow" },
        keywords   = { "bright", "magenta" },
        identifier = { "blue" },
        builtin    = { "bright", "underscore", "green" }
    },

    help = "croissant.help",

    dump = {
        depthLimit = 5,
        itemsLimit = 30
    }
}

-- Read from ~/.croissantrc
local user = {}
local file, _ = io.open(os.getenv "HOME" .. "/.croissantrc", "r")

if file then
    local rc = file:read("*all")

    file:close()

    rc = load(rc) or load("return " .. rc)

    if rc then
        user = rc()
    end
end

-- Merge default and user
local conf = merge(default, user)

-- Convert colors to escape codes
for k, v in pairs(conf.syntaxColors) do
    local color = ""

    for _, c in ipairs(v) do
        color = color .. colors[c]
    end

    conf.syntaxColors[k] = color
end

-- Convert keybding to escape codes
for command, bindings in pairs(conf.keybinding) do
    local bds = {}

    for _, key in ipairs(bindings) do
        local prefix, suffix = key:match "^([CM])-(.*)"

        if prefix then
            table.insert(bds, char[prefix](suffix))
        else
            table.insert(bds, key)
        end
    end

    conf.keybinding[command] = bds
end

return conf
