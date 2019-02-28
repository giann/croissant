local colors      = require "term.colors"
local conf        = require "croissant.conf"
local LuaPrompt   = require "croissant.luaprompt"
local Lexer       = require "croissant.lexer"
local cdo         = require "croissant.do"
local runChunk    = cdo.runChunk
local frameEnv    = cdo.frameEnv
local bindInFrame = cdo.bindInFrame
local banner      = cdo.banner
local runFile     = cdo.runFile

local repeatableCommands = {
    "continue",
    "down",
    "next",
    "out",
    "step",
    "up",
}

-- Warning: Order matters. When truncated command name are used, will match the first one in these tables.

-- Commands allowed when detached
local detachedCommands = {
    "breakpoint",
    "clear",
    "delete",
    "disable",
    "enable",
    "info",
    "run",
}

-- Commands allowed when attached
local attachedCommands = {
    "breakpoint",
    "continue",
    "clear",
    "down",
    "delete",
    "disable",
    "enable",
    "info",
    "next",
    "out",
    "step",
    "trace",
    "up",
    "where",
}

local function highlight(code)
    local lexer = Lexer()
    local highlighted = ""

    for kind, text, _ in lexer:tokenize(code) do
        highlighted = highlighted
            .. (conf.syntaxColors[kind] or "")
            .. text
            .. colors.reset
    end

    return highlighted
end

return function(script, breakpoints, fromCli)
    breakpoints = breakpoints or {}
    local history = cdo.loadDebugHistory()

    local frame = 0
    -- When fromCli we don't want to break right away
    local frameLimit = not fromCli and -2 or false
    local currentFrame = 0

    local lastCommand, commands

    local function breakpointCount()
        local count = 0
        for _, lines in pairs(breakpoints) do
            for _, _ in pairs(lines) do
                count = count + 1
            end
        end

        return count
    end

    local function doREPL(detached)
        local rframe, fenv, env, rawenv, multiline
        while true do
            if rframe ~= currentFrame and not detached then
                rframe = currentFrame

                commands.where()

                fenv, rawenv = frameEnv(true, currentFrame)
                env = setmetatable({}, {
                    __index = fenv,
                    __newindex = function(env, name, value)
                        bindInFrame(8 + currentFrame, name, value, env)
                    end
                })
            elseif detached then
                env = _G
                rawenv = _G
            end

            local prompt = colors.reset
                .. "["
                .. colors.green(script)
                .. "] "
                .. (not multiline and conf.prompt or conf.continuationPrompt)

            if not detached then
                local info = debug.getinfo(3 + (currentFrame or 0))

                prompt = colors.reset
                    .. "[" .. currentFrame .. "]"
                    .. "["
                    .. colors.green(info.short_src)
                    .. (info.name and ":" .. colors.blue(info.name) or "")
                    .. (info.currentline > 0 and ":" .. colors.yellow(info.currentline) or "")
                    .. "] "
                    .. (not multiline and conf.prompt or conf.continuationPrompt)
            end

            local code = LuaPrompt {
                parsing     = not detached,
                env         = rawenv,
                prompt      = prompt,
                multiline   = multiline,
                history     = history,
                tokenColors = conf.syntaxColors,
                help        = require(conf.help),
                quit        = function() end
            }:ask()

            if code ~= "" and (not history[1] or history[1] ~= code) then
                table.insert(history, 1, code)

                cdo.appendToDebugHistory(code)
            end

            -- If empty replay previous command
            if code == "" then
                code = lastCommand
            end

            if code and code ~= "" then
                -- Is it a command ?
                local cmd
                local allowed = detached and detachedCommands or attachedCommands
                for _, command in ipairs(allowed) do
                    local codeCommand, codeArgs = code:match "^(%g+)(.*)"
                    if command == codeCommand
                        or command:sub(1, #codeCommand) == codeCommand then

                        local repeatable = false
                        for _, c in ipairs(repeatableCommands) do
                            if c == command then
                                repeatable = true
                                break
                            end
                        end

                        lastCommand = repeatable and code or lastCommand

                        cmd = command
                        local args = {}
                        for arg in codeArgs:gmatch "(%g+)" do
                            table.insert(args, arg)
                        end
                        if commands[command](table.unpack(args)) then
                            return
                        end

                        break
                    end
                end

                -- Don't run any chunk if detached
                if not cmd and not detached then
                    if runChunk((multiline or "") .. code, env) then
                        multiline = (multiline or "") .. code .. "\n"
                    else
                        multiline = nil
                    end
                elseif not cmd then
                    print(colors.red "Command not recognized")
                end
            end
        end
    end

    local function hook(event, line)
        -- if event == "line" then
        --     print(line, debug.getinfo(2).source, frame, frameLimit)
        -- end

        if event == "line" and frameLimit and frame <= frameLimit then
            doREPL()
        elseif event == "line" then
            local info = debug.getinfo(2)
            local breaks = breakpoints[info.source:sub(2)]

            -- -1 means `break at first line of code`
            if breaks and (breaks[tonumber(line)] or breaks[-1]) then
                breaks[-1] = nil

                if not frameLimit then
                  
                    frameLimit = frame
                end
                doREPL()
            end
        elseif event == "call" then
            frame = frame + 1
            currentFrame = 0
        elseif event == "return" then
            frame = frame - 1
            currentFrame = 0
        end
    end

    commands = {
        breakpoint = function(source, line)
            if source and line then
                -- Get breakpoints count
                local count = breakpointCount()

                -- Args can come from user
                line = tonumber(line)

                breakpoints[source] = breakpoints[source] or {}

                breakpoints[source][line] = true

                print(colors.green("Breakpoint #" .. count + 1 .. " added"))
            else
                print(colors.yellow "Where required")
            end
        end,

        clear = function()
            breakpoints = {}
        end,

        delete = function(breakpoint)
            if breakpoint then
                breakpoint = tonumber(breakpoint)
                local count = 1
                for _, lines in pairs(breakpoints) do
                    for l, _ in pairs(lines) do
                        if count == breakpoint then
                            lines[l] = nil

                            print(colors.yellow("Breakpoint #" .. breakpoint .. " deleted"))
                            return
                        end

                        count = count + 1
                    end
                end

                print(colors.yellow("Could not find breakpoint #" .. breakpoint))
            else
                print(colors.yellow "No breakpoint id provided")
            end
        end,

        enable = function(breakpoint)
            if breakpoint then
                breakpoint = tonumber(breakpoint)
                local count = 1
                for _, lines in pairs(breakpoints) do
                    for l, _ in pairs(lines) do
                        if count == breakpoint then
                            lines[l] = true

                            print(colors.yellow("Breakpoint #" .. breakpoint .. " enabled"))
                            return
                        end

                        count = count + 1
                    end
                end

                print(colors.yellow("Could not find breakpoint #" .. breakpoint))
            else
                print(colors.yellow "No breakpoint id provided")
            end
        end,

        disable = function(breakpoint)
            if breakpoint then
                breakpoint = tonumber(breakpoint)
                local count = 1
                for _, lines in pairs(breakpoints) do
                    for l, _ in pairs(lines) do
                        if count == breakpoint then
                            lines[l] = false

                            print(colors.yellow("Breakpoint #" .. breakpoint .. " disabled"))
                            return
                        end

                        count = count + 1
                    end
                end

                print(colors.yellow("Could not find breakpoint #" .. breakpoint))
            else
                print(colors.yellow "No breakpoint id provided")
            end
        end,

        info = function(what)
            if not what then
                print(colors.yellow "Info on what ?")

                return
            end

            if what == "breakpoints" then
                local count = 1
                local breakStr = ""
                for s, lines in pairs(breakpoints) do
                    for l, on in pairs(lines) do
                        breakStr = breakStr ..
                            "\n      "
                            .. count .. ". "
                            .. colors.green(s) .. ":"
                            .. colors.yellow(l) .. " "
                            .. (on and colors.green "on" or colors.bright(colors.black("off")))
                        count = count + 1
                    end
                end

                if breakStr ~= "" then
                    print(breakStr .. "\n")
                else
                    print(colors.yellow "No breakpoint defined")
                end
            end
        end,

        step = function()
            frameLimit = frame + 1
            return true
        end,

        next = function()
            frameLimit = frame
            return true
        end,

        out = function()
            frameLimit = frame - 1
            return true
        end,

        up = function()
            if currentFrame + 1 > frame then
                print(colors.yellow "No further context")
                return false
            end

            currentFrame = math.min(currentFrame + 1, frame)

            return false
        end,

        down = function()
            if currentFrame - 1 < 0 then
                print(colors.yellow "No further context")
                return false
            end

            currentFrame = math.max(0, currentFrame - 1)

            return false
        end,

        trace = function()
            local trace = ""
            local info
            local i = 4
            repeat
                info = debug.getinfo(i)

                if info then
                    trace = trace ..
                        (i - 4 == currentFrame
                            and colors.bright(colors.green("    ❱ " .. (i - 4) .. " │ "))
                            or  colors.bright(colors.black("      " .. (i - 4) .. " │ ")))
                        .. colors.green(info.short_src) .. ":"
                        .. (info.currentline > 0 and colors.yellow(info.currentline) .. ":" or "")
                        .. " in " .. colors.magenta(info.namewhat)
                        .. colors.blue((info.name and " " .. info.name) or (info.what == "main" and "main chunk") or " ?")
                        .. "\n"
                end

                i = i + 1
            until not info or i - 4 > frame

            print("\n" .. trace)

            return false
        end,

        where = function()
            local info = debug.getinfo(4 + (currentFrame or 0))

            local source = ""
            local srcType = info.source:sub(1, 1)
            if srcType == "@" then
                local file, _ = io.open(info.source:sub(2), "r")

                if file then
                    source = file:read("*all")

                    file:close()
                end
            elseif srcType == "=" then
                source = info.source:sub(2)
            else
                source = info.source
            end

            source = highlight(source)

            local lines = {}
            for line in source:gmatch("([^\n]*)\n") do
                table.insert(lines, line)
            end

            local minLine = math.max(1, info.currentline - 4)
            local maxLine = math.min(#lines, info.currentline + 4)

            local w = ""
            for count, line in ipairs(lines) do
                if count >= minLine
                    and count <= maxLine then
                    w = w ..
                        (count == info.currentline
                            and colors.bright(colors.green("    ❱ " .. count .. " │ ")) .. line
                            or  colors.bright(colors.black("      " .. count .. " │ ")) .. line)
                        .. "\n"
                end
            end

            print("\n      [" .. currentFrame .. "] " .. colors.green(info.short_src) .. ":"
                    .. (info.currentline > 0 and colors.yellow(info.currentline) .. ":" or "")
                    .. " in " .. colors.magenta(info.namewhat)
                    .. colors.blue((info.name and " " .. info.name) or (info.what == "main" and "main chunk") or " ?"))
            print(colors.reset .. w)

            return false, w
        end,

        continue = function()
            for _, v in pairs(breakpoints) do
                -- luacheck: push ignore 512
                for _, _ in pairs(v) do
                    -- There's at least one breakpoint: don't clear hooks
                    frameLimit = false
                    return true
                end
                -- luacheck: pop
            end

            -- No breakpoints: clear hooks
            debug.sethook()
            return true
        end,

        run = function(...)
            debug.sethook(hook, "clr")

            if script then
                runFile(script)
            end
        end,
    }

    banner()

    if fromCli then
        doREPL(true)
    else
        -- We're required inside a script, debug.sethook must be the last instruction otherwise
        -- we'll break at the last debugger instruction
        debug.sethook(hook, "clr")
    end
end
