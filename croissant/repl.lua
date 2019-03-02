require "compat53"

local conf      = require "croissant.conf"
local cdo       = require "croissant.do"
local runChunk  = cdo.runChunk
local banner    = cdo.banner

local LuaPrompt = require "croissant.luaprompt"

return function()
    local history = cdo.loadHistory()
    local multiline = false
    local finished = false

    _G.quit = function()
        finished = true
    end

    banner()

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
