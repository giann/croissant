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

        s = s .. "{\n"

        for k, v in pairs(t) do
            s = s .. ("     "):rep(inc)

            local typeK = type(k)
            local typeV = type(v)

            if typeK == "table" and not seen[v] then
                s = s  .. "["
                    .. dump(k, inc + 1)
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
                s = s .. dump(v, inc + 1) .. ",\n"
            elseif typeV == "string" then
                s = s .. colors.green .. "\"" .. v:format("%q") .. "\"" .. colors.reset .. ",\n"
            else
                s = s .. colors.yellow .. tostring(v) .. colors.reset .. ",\n"
            end
        end

        s = s .. ("\t"):rep(inc - 1).. "}"

        return s
    elseif type(t) == "string" then
        return colors.green .. "\"" .. t:format("%q") .. "\"" .. colors.reset
    end

    return colors.yellow .. tostring(t) .. colors.reset
end

return function()
    print(COPYRIGHT)

    while true do
        local code = LuaPrompt():ask()

        local fn, err = load("return " .. code, "croissant")
        if not fn then
            fn, err = load(code, "croissant")
        end

        if fn then
            local result = table.pack(fn())
            local dumps = {}
            for _, r in ipairs(result) do
                table.insert(dumps, dump(r))
            end

            print(table.concat(dumps))
        else
            print(colors.red .. err .. colors.reset)
        end
    end
end