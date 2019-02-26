local colors    = require "term.colors"
local conf      = require "croissant.conf"
local cdo       = require "croissant.do"
local runChunk  = cdo.runChunk

local LuaPrompt = require "croissant.luaprompt"

if tonumber(_VERSION:match("Lua (%d+)")) < 5
    or tonumber(_VERSION:match("Lua %d+%.(%d+)")) < 3 then
    print(colors.red "Croissant requires at least Lua 5.3")
    os.exit(1)
end

local COPYRIGHT =
    "🥐  Croissant 0.0.1 (C) 2019 Benoit Giannangeli\n"
    .. _VERSION ..  " Copyright (C) 1994-2018 Lua.org, PUC-Rio"

return function()
    print(COPYRIGHT)

    local history = cdo.loadHistory()
    local multiline = false
    local finished = false

    _G.quit = function()
        finished = true
    end

    while not finished do
        local code = LuaPrompt {
            prompt      = multiline and conf.continuationPrompt or conf.prompt,
            multiline   = multiline,
            history     = history,
            tokenColors = conf.syntaxColors,
            help        = require(conf.help),
            quit        = _G.quit
        }:ask()

        if code ~= "" and (not history[1] or history[1] ~= code) then
            table.insert(history, 1, code)

            cdo.appendToHistory(code)
        end

        if runChunk((multiline or "") .. code) then
            multiline = (multiline or "") .. code .. "\n"
        else
            multiline = nil
        end
    end
end
