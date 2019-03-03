local colors = require "term.colors"
local conf   = require "croissant.conf"

local dump
dump = function(t, inc, seen)
    if type(t) == "table" and (inc or 0) < conf.dump.depthLimit then
        inc = inc or 1
        seen = seen or {}

        seen[t] = true

        io.write(
            "{  "
            .. colors.dim .. colors.cyan .. "-- " .. tostring(t) .. colors.reset
            .. "\n"
        )

        local metatable = getmetatable(t)
        if metatable then
            io.write(
                ("     "):rep(inc)
                    .. colors.dim(colors.cyan "metatable = ")
            )
            if not seen[metatable] then
                dump(metatable, inc + 1, seen)
                io.write ",\n"
            else
                io.write(colors.yellow .. tostring(metatable) .. colors.reset .. ",\n")
            end
        end

        local count = 0
        for k, v in pairs(t) do
            count = count + 1

            if count > conf.dump.itemsLimit then
                io.write(("     "):rep(inc) .. colors.dim(colors.cyan("...")) .. "\n")
                break
            end

            io.write(("     "):rep(inc))

            local typeK = type(k)
            local typeV = type(v)

            if typeK == "table" and not seen[v] then
                io.write "["

                dump(k, inc + 1, seen)

                io.write "] = "
            elseif typeK == "string" then
                io.write(colors.blue .. k:format("%q") .. colors.reset
                    .. " = ")
            else
                io.write("["
                    .. colors.yellow .. tostring(k) .. colors.reset
                    .. "] = ")
            end

            if typeV == "table" and not seen[v] then
                dump(v, inc + 1, seen)
                io.write ",\n"
            elseif typeV == "string" then
                io.write(colors.green .. "\"" .. v .. "\"" .. colors.reset .. ",\n")
            else
                io.write(colors.yellow .. tostring(v) .. colors.reset .. ",\n")
            end
        end

        io.write(("     "):rep(inc - 1).. "}")

        return
    elseif type(t) == "string" then
        io.write(colors.green .. "\"" .. t .. "\"" .. colors.reset)

        return
    end

    io.write(colors.yellow .. tostring(t) .. colors.reset)
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
local function runChunk(code, env, name)
    env = env or _G

    local fn, err = load("return " .. code, name or "croissant", "t", env)
    if not fn then
        fn, err = load(code, name or "croissant", "t", env)
    end

    if fn then
        local result = table.pack(xpcall(fn, debug.traceback))

        if result[1] then
            for i = 2, result.n do
                local r = result[i]
                dump(r)
                io.write "\t"
            end

            if result.n < 2 then
                -- Look for assignments
                local names = { code:match "^([^{=]+)%s?=[^=]" }
                if names then
                    for _, n in ipairs(names) do
                        local assignement = load("return " .. n)
                        local assigned = assignement and assignement()
                        if assigned then
                            dump(assigned)
                            io.write "\t"
                        end
                    end
                end

                io.write "\n"
            else
                io.write "\n"
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

local function runFile(script, arguments)
    arguments = arguments or {}

    -- Run file
    local fn, err = loadfile(script)

    if not fn then
        print(colors.red(err))
        return
    end

    local result = table.pack(xpcall(fn, debug.traceback, table.unpack(arguments)))

    if not result[1] then
        print(colors.red(result[2]))
        return
    end

    if result.n > 1 then
        io.write(colors.bright(colors.blue("\nReturned values:\n")))

        for i = 2, result.n do
            local r = result[i]
            dump(r)
            io.write "\t"
        end

        io.write "\n"
    end
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

local function luaVersion()
    local f = function()
        return function()
        end
    end

    local t = {
        nil,
        [false] = "Lua 5.1",
        [true] = "Lua 5.2",
        [1/"-0"] = "Lua 5.3",
        [1] = "LuaJIT"
    }

    return t[1] or t[1/0] or t[f() == f()]
end

local function banner()
    local version = luaVersion()

    if tonumber(_VERSION:match("Lua (%d+)")) < 5
        or tonumber(_VERSION:match("Lua %d+%.(%d+)")) < 1 then
        print(colors.red "Croissant requires at least Lua 5.1")
        os.exit(1)
    end

    print(
        "🥐  Croissant 0.0.1 (C) 2019 Benoit Giannangeli\n"
        .. version ..  (version:match "^LuaJIT"
                and " Copyright (C) 2005-2017 Mike Pall. http://luajit.org/"
                or " Copyright (C) 1994-2018 Lua.org, PUC-Rio")
    )
end

return {
    banner               = banner,
    appendToDebugHistory = appendToDebugHistory,
    appendToHistory      = appendToHistory,
    bindInFrame          = bindInFrame,
    dump                 = dump,
    frameEnv             = frameEnv,
    loadHistory          = loadHistory,
    runChunk             = runChunk,
    loadDebugHistory     = loadDebugHistory,
    runFile              = runFile,
}
