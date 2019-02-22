local colors = require "term.colors"

local LuaPrompt = require "croissant.luaprompt"

local COPYRIGHT =
    "🥐  Croissant 0.0.1  (C) 2019 Benoit Giannangeli\n" ..
    "Lua 5.3.5  Copyright (C) 1994-2018 Lua.org, PUC-Rio"

local dump
dump = function(t, inc, seen)
    if type(t) == "table" then
        local s = ""
        inc = inc or 1
        seen = seen or {}

        seen[t] = true

        s = s
            .. "{  "
            .. colors.dim .. colors.cyan .. "-- " .. tostring(t) .. colors.reset
            .. "\n"

        for k, v in pairs(t) do
            s = s .. ("     "):rep(inc)

            local typeK = type(k)
            local typeV = type(v)

            if typeK == "table" and not seen[v] then
                s = s  .. "["
                    .. dump(k, inc + 1, seen)
                    .. "] = "
            elseif typeK == "string" then
                s = s .. colors.blue .. k:format("%q") .. colors.reset
                    .. " = "
            else
                s = s  .. "["
                    .. colors.yellow .. tostring(k) .. colors.reset
                    .. "] = "
            end

            if typeV == "table" and not seen[v] then
                s = s .. dump(v, inc + 1, seen) .. ",\n"
            elseif typeV == "string" then
                s = s .. colors.green .. "\"" .. v .. "\"" .. colors.reset .. ",\n"
            else
                s = s .. colors.yellow .. tostring(v) .. colors.reset .. ",\n"
            end
        end

        s = s .. ("\t"):rep(inc - 1).. "}"

        return s
    elseif type(t) == "string" then
        return colors.green .. "\"" .. t .. "\"" .. colors.reset
    end

    return colors.yellow .. tostring(t) .. colors.reset
end

return function()
    print(COPYRIGHT)

    local history = {}
    local multiline = false
    local finished = false

    _G.quit = function()
        finished = true
    end

    while not finished do
        local code = LuaPrompt {
            prompt = multiline and ".... ",
            multiline = multiline,
            history = history
        }:ask()

        table.insert(history, code)

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
                print(colors.red .. err .. colors.reset)
            end
        end
    end
end
