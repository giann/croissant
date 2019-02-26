local colors      = require "term.colors"
local conf        = require "croissant.conf"
local LuaPrompt   = require "croissant.luaprompt"
local Lexer       = require "croissant.lexer"
local cdo         = require "croissant.do"
local runChunk    = cdo.runChunk
local frameEnv    = cdo.frameEnv
local bindInFrame = cdo.bindInFrame

local function doREPL(commands, history)
    local _, where = commands.where()
    print(colors.reset .. "\n" .. where .. "\n")

    local fenv, rawenv = frameEnv(true)
    local env = setmetatable({}, {
        __index = fenv,
        __newindex = function(env, name, value)
            bindInFrame(8, name, value, env)
        end
    })

    local multiline
    while true do
        local info = debug.getinfo(4)

        local code = LuaPrompt {
            env         = rawenv,
            prompt      = "["
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

        -- Is it a command ?
        local cmd
        for command, fn in pairs(commands) do
            if command == code then
                cmd = command
                if fn() then
                    return
                end
            end
        end

        if code ~= "" and (not history[1] or history[1] ~= code) then
            table.insert(history, 1, code)

            cdo.appendToDebugHistory(code)
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

return function()
    local history = cdo.loadHistory()

    local frame = 0
    local frameLimit = -2

    local commands
    commands = {
        step = function()
            frameLimit = -1
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
            return true
        end,

        down = function()
            return true
        end,

        where = function()
            local info = debug.getinfo(4)

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

            return false, w
        end,

        continue = function()
            debug.sethook()
            return true
        end,
    }

    debug.sethook(function(event, line)
        if event == "line" and frame <= frameLimit then
            doREPL(commands, history)
        elseif event == "call" then
            frame = frame + 1
        elseif event == "return" then
            frame = frame - 1
        end
    end, "clr")
end
