require "compat53"

local colors      = require "term.colors"
local argparse    = require "argparse"
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
    "finish",
    "step",
    "up",
}

-- Commands allowed when detached
local detachedCommands = {
    "args",
    "breakpoint",
    "clear",
    "condition",
    "depth",
    "delete",
    "disable",
    "display",
    "enable",
    "exit",
    "help",
    "info",
    "run",
    "undisplay",
    "watch",
}

-- Commands allowed when attached
local attachedCommands = {
    "breakpoint",
    "clear",
    "condition",
    "continue",
    "depth",
    "delete",
    "disable",
    "display",
    "down",
    "enable",
    "eval",
    "exit",
    "help",
    "info",
    "next",
    "finish",
    "step",
    "trace",
    "undisplay",
    "up",
    "watch",
    "where",
}

local commandErrorMessage
local commandsHelp = {}

local parser = argparse()
parser._name = ""

local runCommand = parser:command "run r"
    :description "Starts your script"

runCommand._options = {}
commandsHelp.run = runCommand:get_help()

local argsCommand = parser:command "args a"
    :description "Set arguments to pass to your script"
argsCommand:argument "arguments"
    :args "+"

argsCommand._options = {}
commandsHelp.args = argsCommand:get_help()

local breakpointCommand = parser:command "breakpoint br b"
    :description("Add a new breakpoint")
breakpointCommand:argument "where"
    :description "Where to break. Function, line number in current file or `file:line`"
    :args(1)
breakpointCommand:argument "when"
    :description "Break only if this Lua expressions can be evaluated to be true"
    :args "*"

breakpointCommand._options = {}
commandsHelp.breakpoint = breakpointCommand:get_help()

local watchCommand = parser:command "watch wa"
    :description("Add a new watchpoint")
watchCommand:argument "expression"
    :description "Break only if this evaluated Lua expression changes value"
    :args "+"

local displayCommand = parser:command "display dp"
    :description("Prints expression each time the program stops")
displayCommand:argument "expression"
    :description "Lua expression to print"
    :args "+"

displayCommand._options = {}
commandsHelp.display = displayCommand:get_help()

local undisplayCommand = parser:command "undisplay undp udp"
    :description("Removes display")
undisplayCommand:argument "id"
    :description "ID of display to remove"
    :args(1)

undisplayCommand._options = {}
commandsHelp.undisplay = undisplayCommand:get_help()

local conditionCommand = parser:command "condition cond"
    :description "Modify breaking condition of a breakpoint"
conditionCommand:argument "id"
    :description "Breakpoint ID"
    :args(1)
conditionCommand:argument "condition"
    :description "New breakpoint condition"
    :args "+"

conditionCommand._options = {}
commandsHelp.condition = conditionCommand:get_help()

local enableCommand = parser:command "enable en"
    :description "Enable a breakpoint"
enableCommand:argument "id"
    :description "Breakpoint ID"
    :args(1)

enableCommand._options = {}
commandsHelp.enable = enableCommand:get_help()

local disableCommand = parser:command "disable dis di"
    :description "Disable a breakpoint"
disableCommand:argument "id"
    :description "Breakpoint ID"
    :args(1)

disableCommand._options = {}
commandsHelp.disable = disableCommand:get_help()

local deleteCommand = parser:command "delete del de d"
    :description "Delete a breakpoint"
deleteCommand:argument "id"
    :description "Breakpoint ID"
    :args(1)

deleteCommand._options = {}
commandsHelp.delete = deleteCommand:get_help()

local clearCommand = parser:command "clear cl"
    :description "Delete all breakpoints, watchpoints and displays"

clearCommand._options = {}
commandsHelp.clear = clearCommand:get_help()

local infoCommand = parser:command "info inf i"
    :description "Get informations about the debugger state"
infoCommand:argument "about"
    :description("`breakpoints` will list breakpoints, "
        .. "`locals` will list locals of the current context, "
        .. "`displays` will list displays")
    :args(1)

infoCommand._options = {}
commandsHelp.info = infoCommand:get_help()

local stepCommand = parser:command "step st s"
    :description "Step in the code (repeatable)"

stepCommand._options = {}
commandsHelp.step = stepCommand:get_help()

local nextCommand = parser:command "next n"
    :description "Step in the code without going over any function call (repeatable)"

nextCommand._options = {}
commandsHelp.next = nextCommand:get_help()

local finishCommand = parser:command "finish f"
    :description "Will break after leaving the current function (repeatable)"

finishCommand._options = {}
commandsHelp.finish = finishCommand:get_help()

local upCommand = parser:command "up u"
    :description "Go up one frame (repeatable)"

upCommand._options = {}
commandsHelp.up = upCommand:get_help()

local downCommand = parser:command "down d"
    :description "Go down one frame (repeatable)"

downCommand._options = {}
commandsHelp.down = downCommand:get_help()

local continueCommand = parser:command "continue cont c"
    :description("Continue until hitting a breakpoint. If no breakpoint are specified,"
        .. " clears debug hooks (repeatable)")

continueCommand._options = {}
commandsHelp.continue = continueCommand:get_help()

local evalCommand = parser:command "eval ev e"
    :description "Evaluates lua code (useful to disambiguate from debugger commands)"
evalCommand:argument "expression"
    :description "Lua expression to evaluate"
    :args "+"

evalCommand._options = {}
commandsHelp.eval = evalCommand:get_help()

local depthCommand = parser:command "depth dep"
    :description "Limit depth at which croissant goes to pretty print returned values"
depthCommand:argument "limit"
    :description "Depth"
    :args(1)
depthCommand:argument "items"
    :description "Items"
    :args "?"

depthCommand._options = {}
commandsHelp.depth = depthCommand:get_help()

local whereCommand = parser:command "where wh w"
    :description("Prints code around the current line. Is ran for you each time you step in"
        .. " the code or change frame context")
whereCommand:argument "rows"
    :description "How many rows to show around the current line"
    :args "?"

whereCommand._options = {}
commandsHelp.where = whereCommand:get_help()

local traceCommand = parser:command "trace tr t"
    :description "Prints current stack trace and highlights current frame"

traceCommand._options = {}
commandsHelp.trace = traceCommand:get_help()

local exitCommand = parser:command "exit ex"
    :description "Quit"

exitCommand._options = {}
commandsHelp.exit = exitCommand:get_help()

local helpCommand = parser:command "help h"
    :description "Prints help message"
helpCommand:argument "about"
    :description "Command for which you want help"
    :args "?"

helpCommand._options = {}
commandsHelp.help = helpCommand:get_help()

-- We don't need any
parser._options = {}

commandsHelp[1] = not commandsHelp[1]
    and parser:get_help()
    or commandsHelp[1]

-- If we can't parse it, raise an error instead of os.exit(0)
parser.error = function(self, msg)
    commandErrorMessage = msg
    error(msg)
end

local function parseCommands(detached, args)
    local ok, parsed = xpcall(parser.parse, function(_)
        return commandErrorMessage
    end, parser, args)

    if ok then
        local keys = {}
        for key, _ in pairs(parsed) do
            table.insert(keys, key)
        end

        -- Zero or one key `about` -> this is help command
        if #keys == 0 or (#keys == 1 and keys[1] == "about") then
            parsed.help = true
        end
    end

    return ok, parsed
end

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

return function(script, arguments, breakpoints, fromCli)
    arguments = arguments or {}
    breakpoints = breakpoints or {}
    local displays = {}
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

                commands.where(nil, -1)

                fenv, rawenv = frameEnv(true, currentFrame)
                env = setmetatable({}, {
                    __index = fenv,
                    __newindex = function(env, name, value)
                        bindInFrame(8 + currentFrame, name, value, env)
                    end
                })

                -- Print displays
                if #displays > 0 then
                    io.write("\n")
                    for id, display in ipairs(displays) do
                        local f = load("return " .. display, "__debugger__", "t", env)
                            or load(display, "__debugger__", "t", env)

                        if not f then
                            print(colors.red("Display #" .. id .. " expression could not be parsed"))
                            return
                        end

                        local ok, value = pcall(f)

                        io.write("      "
                            .. id .. ". `"
                            .. highlight(display) .. "`: ")

                        if ok then
                            cdo.dump(value)
                        else
                            io.write("failed with error: " .. colors.red(value))
                        end
                    end
                    io.write("\n\n")
                end
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
                quit        = function() end,
                builtins    = detached and detachedCommands or attachedCommands
            }:ask()

            if code ~= "" and (not history[1] or history[1] ~= code) then
                table.insert(history, 1, code)

                cdo.appendToDebugHistory(code)
            end

            -- If empty replay previous command
            if code == "" then
                code = lastCommand
            end

            local badCommand
            if code and code ~= "" then
                -- Is it a command ?
                local words = {}
                for word in code:gmatch "(%g+)" do
                    table.insert(words, word)
                end

                local ok, parsed = parseCommands(detached, words)
                local cmd
                if ok then
                    local allowed = detached and detachedCommands or attachedCommands
                    for _, command in ipairs(allowed) do
                        if parsed[command] then
                            if command == "eval" then
                                code = table.concat(parsed.expression, " ")
                                break
                            end

                            local repeatable = false
                            for _, c in ipairs(repeatableCommands) do
                                if c == command then
                                    repeatable = true
                                    break
                                end
                            end

                            lastCommand = repeatable and code or lastCommand

                            cmd = command
                            local cmdOk, continue = pcall(commands[command], parsed)
                            if cmdOk and continue then
                                return
                            elseif not cmdOk then
                                -- Something broke, bail
                                print(colors.red "Error in debugger command, quitting", continue)
                                debug.sethook()
                                return
                            end

                            break
                        end
                    end
                elseif not parsed:match "^unknown command" then
                    print(colors.yellow(parsed))
                    badCommand = true
                end

                -- Don't run any chunk if detached
                if not badCommand and not cmd and not detached then
                    if runChunk((multiline or "") .. code, env, "__debugger__") then
                        multiline = (multiline or "") .. code .. "\n"
                    else
                        multiline = nil
                    end
                end
            end
        end
    end

    local function countTrace(trace)
        local count = 1
        for _ in trace:gmatch "\n" do
            count = count + 1
        end
        return count
    end

    local lastEnteredFunction
    local first = true
    local stackDepth, previousStackDepth
    local function hook(event, line)
        local info = debug.getinfo(2)
        previousStackDepth = stackDepth
        stackDepth = countTrace(debug.traceback())

        if previousStackDepth and (previousStackDepth < stackDepth) then -- call
            frame = frame + 1
            currentFrame = 0

            lastEnteredFunction = info.name
        elseif previousStackDepth and (previousStackDepth > stackDepth) then -- return
            frame = frame - 1
            currentFrame = 0
        end

        -- Don't debug code from watchpoints/breakpoints/displays
        if info.source == "[string \"__debugger__\"]" then
            return
        end

        if (frameLimit and frame <= frameLimit) or (first and not fromCli) then
            frameLimit = first and frame or frameLimit
            first = false
            doREPL(false)
        else
            local breaks = breakpoints[info.source:sub(2)]
            local breakpoint = breaks and breaks[tonumber(line)]

            if not breakpoint
                and (breakpoints[-1] and breakpoints[-1][info.name] and lastEnteredFunction == info.name) then
                breaks = breakpoints[-1]
                breakpoint = breakpoints[-1][info.name]
            end

            if not breakpoint
                and (breakpoints[-1] and breakpoints[-1][-1]) then
                breaks = breakpoints[-1]
                breakpoint = breakpoints[-1][-1]
            end

            local breakType = type(breakpoint)
            -- -1 means `break at any line of code`
            if breaks and breakpoint then
                lastEnteredFunction = nil

                local fenv, env, watchpointChanged
                if breakType == "string" or breakType == "table" then
                    fenv = frameEnv(true, currentFrame - 1)
                    env = setmetatable({}, {
                        __index = fenv,
                        __newindex = function(env, name, value)
                            bindInFrame(8 + 2, name, value, env)
                        end
                    })
                end

                if breakType == "string" then -- Breakpoint condition
                    local f = load("return " .. breakpoint, "__debugger__", "t", env)
                        or load(breakpoint, "__debugger__", "t", env)

                    if not f then
                        return
                    end

                    local ok, value = pcall(f)

                    if not ok then
                        print(colors.red("Breakpoint condition failed with error: ".. value))
                    end

                    if not ok or not value then
                        return
                    end
                elseif breakType == "table" then -- Watchpoints
                    for _, watchpoint in ipairs(breakpoint) do
                        local f = load("return " .. watchpoint.expression, "__debugger__", "t", env)
                            or load(watchpoint.expression, "__debugger__", "t", env)

                        if f then
                            local ok, newValue = pcall(f)

                            if ok then
                                if newValue ~= watchpoint.lastValue then
                                    watchpointChanged = watchpointChanged or {}
                                    table.insert(watchpointChanged, watchpoint)
                                end
                                watchpoint.previousValue = watchpoint.lastValue
                                watchpoint.lastValue = newValue
                            else
                                print(colors.red("Watchpoint expression failed with error: " .. newValue))
                            end
                        end
                    end

                    if not watchpointChanged then
                        return
                    end
                end

                if not frameLimit then
                    frameLimit = frame
                end

                if watchpointChanged and #watchpointChanged > 0 then
                    io.write("\n")
                    for _, changed in ipairs(watchpointChanged) do
                        io.write(
                            "`" .. highlight(changed.expression) .. "`"
                            .. " changed from "
                        )


                        cdo.dump(changed.previousValue)

                        io.write(" to ")

                        cdo.dump(changed.lastValue)
                    end
                    io.write("\n")
                end

                doREPL(false)
            end
        end
    end

    commands = {
        help = function(parsed)
            print(
                colors.blue(
                    "\n" ..
                    (parsed.about
                        and commandsHelp[parsed.about]
                            :gsub(" and exit", "")
                        or commandsHelp[1]
                            :gsub("^[^\n]*\n+Commands:\n", "") -- Remove usage line
                            :gsub(" and exit", "")) ..
                    "\n"
                )
            )
        end,

        exit = function()
            os.exit()
        end,

        args = function(parsed)
            arguments = parsed.arguments
        end,

        depth = function(parsed)
            conf.dump.depthLimit = tonumber(parsed.limit)
            conf.dump.itemsLimit = tonumber(parsed.items) or conf.dump.itemsLimit
        end,

        breakpoint = function(parsed)
            -- Get breakpoints count
            local count = breakpointCount()

            -- Condition
            local condition = table.concat(parsed.when, " ")
            local cond = true
            if condition and condition ~= "" and (load("return " .. condition) or load(condition)) then
                cond = condition
            elseif condition and condition ~= "" then
                print(colors.yellow "Condition `" .. condition .. "` could not be parsed")
                return
            end

            -- Line in inspected current file
            if tonumber(parsed.where) then
                if script then
                    breakpoints[script] = breakpoints[script] or {}
                    breakpoints[script][tonumber(parsed.where)] = cond
                else
                    -- TODO: get current script ~= debugger
                    print(colors.red "Could not defer current file")
                end
            elseif parsed.where:match "^([^:]*):(%d+)$" then -- Line in a file
                local file, line = parsed.where:match "^([^:]*):(%d+)$"

                breakpoints[file] = breakpoints[file] or {}
                breakpoints[file][tonumber(line)] = cond
            else                                             -- Function name
                breakpoints[-1] = breakpoints[-1] or {}
                breakpoints[-1][parsed.where] = cond
            end

            print(colors.green("Breakpoint #" .. count + 1 .. " added"))
        end,

        watch = function(parsed)
            -- Get breakpoints count
            local count = breakpointCount()

            local expression = table.concat(parsed.expression, " ")
            if not load("return " .. expression) and not load(expression) then
                print(colors.red "Expression could not be parsed")
                return
            end

            breakpoints[-1] = breakpoints[-1] or {}
            breakpoints[-1][-1] = breakpoints[-1][-1] or {}

            table.insert(breakpoints[-1][-1], {
                expression = expression,
                lastValue = nil
            })

            print(colors.green("Watchpoint #" .. count + 1 .. " added"))
        end,

        condition = function(parsed)
            -- Condition
            local cond = true
            local condition = table.concat(parsed.condition, " ")
            if condition and load("return " .. condition) or load(condition) then
                cond = condition
            end

            local breakpoint = tonumber(parsed.id)
            local count = 1
            for _, lines in pairs(breakpoints) do
                for l, _ in pairs(lines) do
                    if count == breakpoint then
                        lines[l] = cond

                        print(colors.yellow("Breakpoint #" .. breakpoint .. " modified"))
                        return
                    end

                    count = count + 1
                end
            end

            print(colors.yellow("Could not find breakpoint #" .. breakpoint))
        end,

        clear = function()
            breakpoints = {}
            displays = {}

            print(colors.yellow "All breakpoints, watchpoints and displays removed")
        end,

        delete = function(parsed)
            local breakpoint = tonumber(parsed.id)
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
        end,

        enable = function(parsed)
            local breakpoint = tonumber(parsed.id)
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
        end,

        disable = function(parsed)
            local breakpoint = tonumber(parsed.id)
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
        end,

        info = function(parsed)
            local what = parsed.about
            if what == "breakpoints" then
                local count = 1
                for s, lines in pairs(breakpoints) do
                    for l, on in pairs(lines) do
                        if l == -1 then
                            for _, watchpoint in ipairs(on) do
                                io.write(
                                    "\n      "
                                    .. count .. ". When `"
                                    .. highlight(watchpoint.expression)
                                    .. "` is different from "
                                )

                                cdo.dump(watchpoint.lastValue)

                                count = count + 1
                            end
                        else
                            io.write(
                                "\n      "
                                .. count .. ". "
                                .. (s ~= -1 and colors.green(s) .. ":" .. colors.yellow(l) or colors.blue(l))
                            )

                            if type(on) == "string" then
                                io.write(" when `"
                                    .. highlight(on)
                                    .. "`"
                                )
                            else
                                io.write(
                                    (on and colors.green " on" or colors.bright(colors.black(" off")))
                                )
                            end
                            count = count + 1
                        end
                    end
                end

                if count > 1 then
                    io.write("\n\n")
                else
                    print(colors.yellow "No breakpoint defined")
                end
            elseif what == "locals" then
                local locals = frameEnv(false, currentFrame + 2)

                local keys = {}
                for k, _ in pairs(locals) do
                    table.insert(keys, k)
                end
                table.sort(keys)

                io.write "\n"
                for _, k in ipairs(keys) do
                    if k ~= "_ENV" and k ~= "(*temporary)" and  k ~= "_G" then
                        io.write(colors.blue(k)
                            .. " = ")

                        cdo.dump(locals[k], 1)

                        io.write "\n"
                    end
                end
                io.write "\n"
            elseif what == "displays" then
                local displayStr = ""
                for id, display in ipairs(displays) do
                    displayStr = displayStr ..
                            "\n      "
                            .. id .. ". `"
                            .. highlight(display)
                            .. "`"
                end
                if displayStr ~= "" then
                    print(displayStr .. "\n")
                else
                    print(colors.yellow "No display defined")
                end
            end
        end,

        display = function(parsed)
            local expression = table.concat(parsed.expression, " ")

            if not load("return " .. expression) and not load(expression) then
                print(colors.red "Expression could not be parsed")
                return
            end

            table.insert(displays, expression)

            print(colors.green("Display #" .. #displays .. " added"))
        end,

        undisplay = function(parsed)
            if displays[tonumber(parsed.id)] then
                table.remove(displays, tonumber(parsed.id))
                print(colors.yellow("Removed display #" .. parsed.id))
            else
                print(colors.red("Could not find display #" .. parsed.id))
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

        finish = function()
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
            local i = 5
            repeat
                info = debug.getinfo(i)

                if info then
                    trace = trace ..
                        (i - 5 == currentFrame
                            and colors.bright(colors.green("    ❱ " .. (i - 5) .. " │ "))
                            or  colors.bright(colors.black("      " .. (i - 5) .. " │ ")))
                        .. colors.green(info.short_src) .. ":"
                        .. (info.currentline > 0 and colors.yellow(info.currentline) .. ":" or "")
                        .. " in " .. colors.magenta(info.namewhat)
                        .. colors.blue((info.name and " " .. info.name) or (info.what == "main" and "main chunk") or " ?")
                        .. "\n"
                end

                i = i + 1
            until not info or i - 5 > frame

            print("\n" .. trace)

            return false
        end,

        where = function(parsed, offset)
            offset = offset or 0
            local info = debug.getinfo(5 + offset + (currentFrame or 0))

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

            local toShow = (parsed and parsed.rows) or conf.whereRows

            local minLine = math.max(1, info.currentline - toShow)
            local maxLine = math.min(#lines, info.currentline + toShow)

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

        run = function()
            -- If not breakpoints, don't hook
            if breakpointCount() > 0 then
                debug.sethook(hook, "l")
            end

            if script then
                runFile(script, arguments)
            end

            debug.sethook()
        end,
    }

    banner()

    if fromCli then
        doREPL(true)
    else
        -- We're required inside a script, debug.sethook must be the last instruction otherwise
        -- we'll break at the last debugger instruction
        return debug.sethook(hook, "l")
    end
end
