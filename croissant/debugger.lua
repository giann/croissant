local colors      = require "term.colors"
local conf        = require "croissant.conf"
local LuaPrompt   = require "croissant.luaprompt"
local Lexer       = require "croissant.lexer"
local cdo         = require "croissant.do"
local runChunk    = cdo.runChunk
local frameEnv    = cdo.frameEnv
local bindInFrame = cdo.bindInFrame

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


return function(breakpoints, fromCli)
    breakpoints = breakpoints or {}
    local history = cdo.loadDebugHistory()

    local frame = 0
    -- When fromCli we don't want to break right away
    local baseFrame = -2
    local frameLimit = not fromCli and baseFrame or false
    local currentFrame = 0

    local commands
    commands = {
        breakpoint = function(source, line)
            if source and line then
                -- Args can come from user
                line = tonumber(line)

                breakpoints[source] = breakpoints[source] or {}

                breakpoints[source][line] = true
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
            frameLimit = baseFrame + 1
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
    }

    local function doREPL()
        local rframe, fenv, env, rawenv, multiline
        while true do
            if rframe ~= currentFrame then
                rframe = currentFrame

                commands.where()

                fenv, rawenv = frameEnv(true, currentFrame)
                env = setmetatable({}, {
                    __index = fenv,
                    __newindex = function(env, name, value)
                        bindInFrame(8 + currentFrame, name, value, env)
                    end
                })
            end

            local info = debug.getinfo(3 + (currentFrame or 0))

            local code = LuaPrompt {
                env         = rawenv,
                prompt      = colors.reset
                    .. "[" .. currentFrame .. "]"
                    .. "["
                    .. colors.green(info.short_src)
                    .. (info.name and ":" .. colors.blue(info.name) or "")
                    .. (info.currentline > 0 and ":" .. colors.yellow(info.currentline) or "")
                    .. "] "
                    .. (not multiline and "→ " or ".... "),
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

            -- Is it a command ?
            local cmd
            for command, fn in pairs(commands) do
                local codeCommand, codeArgs = code:match "^(%g+)(.*)"
                if command == codeCommand then
                    cmd = command
                    local args = {}
                    for arg in codeArgs:gmatch "(%g+)" do
                        table.insert(args, arg)
                    end
                    if fn(table.unpack(args)) then
                        return
                    end
                end
            end

            if not cmd then
                if runChunk((multiline or "") .. code, env) then
                    multiline = (multiline or "") .. code .. "\n"
                else
                    multiline = nil
                end
            end
        end
    end

    debug.sethook(function(event, line)
        if event == "line" and frameLimit and frame <= frameLimit then --and frame > baseFrame then
            doREPL(currentFrame, commands, history)
        elseif event == "line" then--and (not baseFrame or frame > baseFrame) then
            local info = debug.getinfo(2)
            local breaks = breakpoints[info.source:sub(2)]

            -- -1 means `break at first line of code`
            if breaks and (breaks[tonumber(line)] or breaks[-1]) then
                breaks[-1] = nil

                if not frameLimit then
                    baseFrame = frame
                    frameLimit = frame
                end
                doREPL(0, commands, history)
            end
        elseif event == "call" then
            frame = frame + 1
            currentFrame = 0
        elseif event == "return" then
            frame = frame - 1
            currentFrame = 0
        end
    end, "clr")
end
