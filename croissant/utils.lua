local colors = require "term.colors"

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

return {
    dump = dump
}
