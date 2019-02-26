local colors = require "term.colors"
local conf   = require "croissant.conf"

local dump
dump = function(t, inc, seen)
    if type(t) == "table" and (inc or 0) < conf.dumpLimit then
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

-- Returns true when more line are needed
local function runChunk(code, env)
    local fn, err = load("return " .. code, "croissant")
    if not fn then
        fn, err = load(code, "croissant")
    end

    if fn then
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
        if err:match("<eof>") then
            return true
        else
            print(colors.red .. err .. colors.reset)
        end
    end

    return false
end

return {
    dump = dump,
    runChunk = runChunk,
}
