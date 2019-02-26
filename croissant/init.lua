local colors = require "term.colors"
local conf   = require "croissant.conf"
local dump   = require "croissant.utils".dump

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

    local history = {}
    local multiline = false
    local finished = false

    _G.quit = function()
        finished = true
    end

    -- Load history
    local historyFile, _ = io.open(os.getenv "HOME" .. "/.croissant_history", "a+")

    if historyFile then
        for line in historyFile:lines() do
            if line ~= "" then
                table.insert(history, 1, ({line:gsub("\\n", "\n")})[1])
            end
        end
    else
        print(colors.yellow "Could not load history file at " .. os.getenv "HOME" .. "/.croissant_history")
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
            historyFile:write(code:gsub("\n", "\\n") .. "\n")
        end

        local fn, err = load("return " .. (multiline or "") .. code, "croissant")
        if not fn then
            fn, err = load((multiline or "") .. code, "croissant")
        end

        if fn then
            multiline = false

            local result = table.pack(xpcall(fn, debug.traceback))

            if result[1] then
                local dumps = {}
                for i = 2, result.n do
                    local r = result[i]
                    table.insert(dumps, dump(r))
                end

                if #dumps > 0 then
                    print(table.concat(dumps, "\t"))
                else
                    -- Look for assignments
                    local names = { code:match("^([^{=]+)%s?=[^=]") }
                    if names then
                        dumps = {}
                        for _, n in ipairs(names) do
                            local assignement = load("return " .. n)
                            local assigned = assignement and assignement()
                            if assigned then
                                table.insert(dumps, dump(assigned))
                            end
                        end

                        print(table.concat(dumps, "\t"))
                    end
                end
            else
                print(
                    colors.red
                    .. result[2]
                    .. colors.reset
                )
            end
        else
            -- Syntax error near <eof>
            if err:match("<eof>") or (err and multiline) then
                multiline = (multiline or "") .. code .. "\n"
            else
                multiline = nil
                print(colors.red .. err .. colors.reset)
            end
        end
    end

    historyFile:close()
end
