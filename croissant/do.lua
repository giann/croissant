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

local function frameEnv(withGlobals, frameOffset)
    local level = 5 + (frameOffset or 0)
    local func = debug.getinfo(level - 1).func
    local env = {}
    -- Shallow copy of _G
    local rawenv = {}
    for k, v in pairs(_G) do
        rawenv[k] = v
    end
    local i

    -- Retrieve the upvalues
    i = 1
    while true do
        local ok, name, value = pcall(debug.getupvalue, func, i)

        if not ok or not name then
            break
        end

        env[name] = value
        rawenv[name] = value
        i = i + 1
    end

    -- Retrieve the locals (overwriting any upvalues)
    i = 1
    while true do
        local ok, name, value = pcall(debug.getlocal, level, i)

        if not ok or not name then
            break
        end

        env[name] = value
        rawenv[name] = value
        i = i + 1
    end

    -- Retrieve the varargs
    local varargs = {}
    i = 1
    while true do
        local ok, name, value = pcall(debug.getlocal, level, -i)

        if not ok or not name then
            break
        end

        varargs[i] = value
        i = i + 1
    end
    if i > 1 then
        env["..."] = varargs
        rawenv["..."] = varargs
    end

    if withGlobals then
        env._ENV = env._ENV or {}
        return setmetatable(env._ENV, {__index = env or _G}), rawenv
    else
        return env
    end
end

local function bindInFrame(frame, name, value, env)
    -- Mutating a local?
    do
        local i = 1
        repeat
            local var = debug.getlocal(frame, i)

            if name == var then
                debug.setlocal(frame, i, value)

                return
            end
            i = i + 1
        until var == nil
    end

    -- Mutating an upvalue?
    local func = debug.getinfo(frame).func
    do
        local i = 1
        repeat
            local var = debug.getupvalue(func, i)
            if name == var then
                debug.setupvalue(func, i, value)

                return
            end
            i = i + 1
        until var == nil
    end

    -- New global
    rawset(_G, name, value)
end

-- Returns true when more line are needed
local function runChunk(code, env)
    env = env or _G

    local fn, err = load("return " .. code, "croissant", "t", env)
    if not fn then
        fn, err = load(code, "croissant", "t", env)
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
            print(colors.red(result[2]))
        end
    else
        -- Syntax error near <eof>
        if err:match("<eof>") then
            return true
        else
            print(colors.red(err))
        end
    end

    return false
end

local function loadHistory()
    local history = {}

    local historyFile = io.open(os.getenv "HOME" .. "/.croissant_history", "r")

    if historyFile then
        for line in historyFile:lines() do
            if line ~= "" then
                table.insert(history, 1, ({line:gsub("\\n", "\n")})[1])
            end
        end

        historyFile:close()
    end

    return history
end

local function loadDebugHistory()
    local history = {}

    local historyFile = io.open(os.getenv "HOME" .. "/.croissant_debugger_history", "r")

    if historyFile then
        for line in historyFile:lines() do
            if line ~= "" then
                table.insert(history, 1, ({line:gsub("\\n", "\n")})[1])
            end
        end

        historyFile:close()
    end

    return history
end

local function appendToHistory(code)
    local historyFile = io.open(os.getenv "HOME" .. "/.croissant_history", "a+")

    if historyFile then
        historyFile:write(code:gsub("\n", "\\n") .. "\n")

        historyFile:close()
    end
end

local function appendToDebugHistory(code)
    local historyFile = io.open(os.getenv "HOME" .. "/.croissant_debugger_history", "a+")

    if historyFile then
        historyFile:write(code:gsub("\n", "\\n") .. "\n")

        historyFile:close()
    end
end

return {
    appendToDebugHistory = appendToDebugHistory,
    appendToHistory      = appendToHistory,
    bindInFrame          = bindInFrame,
    dump                 = dump,
    frameEnv             = frameEnv,
    loadHistory          = loadHistory,
    runChunk             = runChunk,
    loadDebugHistory     = loadDebugHistory,
}
