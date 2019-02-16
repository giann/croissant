local Class  = require "hump.class"
local colors = require "term.colors"
local Prompt = require "sirocco.prompt"

local Lexer = require "croissant.lexer"

local LuaPrompt
LuaPrompt = Class {

    __includes = Prompt,

    init = function(self, options)
        options = options or {}

        Prompt.init(self, {
            prompt = options.prompt or "→ ", -- "🥐  ",
            validator = function(code)
                return LuaPrompt.validateLua(self.multiline .. code)
            end,
            required = false
        })

        self.multiline = options.multiline or ""

        -- History
        self.history = options.history or {}
        self.historyIndex = #self.history + 1
        self.historyPrefixIndex = ""

        -- Lexing
        self.tokens = {}
        self.lexer = Lexer()
        -- Buffer whithout colors
        self.highlightedBuffer = ""

        self.tokenColors = options.colors or {
            constant   = colors.bright .. colors.yellow,
            string     = colors.green,
            comment    = colors.bright .. colors.black,
            number     = colors.yellow,
            operator   = colors.yellow,
            keywords   = colors.bright .. colors.magenta,
            identifier = colors.blue,
        }
    end

}

function LuaPrompt:registerKeybinding()
    Prompt.registerKeybinding(self)

    self.keybinding[Prompt.escapeCodes.cursor_up]   = function()
        self:selectHistory(-1)
    end

    self.keybinding[Prompt.escapeCodes.cursor_down] = function()
        self:selectHistory(1)
    end

    local promptBackspace = self.keybinding["\127"]
    self.keybinding["\127"] = function()
        promptBackspace()

        self:renderHighlighted()

        self.message = nil
    end

    local clearline = self.keybinding["\11"]
    self.keybinding["\11"] = function()
        clearline()

        self:renderHighlighted()

        self.message = nil
    end
end

function LuaPrompt:selectHistory(dt)
    local filteredHistory = {}

    if utf8.len(self.buffer) > 0 then
        self.historyPrefixIndex = utf8.len(self.historyPrefixIndex) > 0
            and self.historyPrefixIndex
            or self.buffer

        for _, entry in ipairs(self.history) do
            if entry:sub(1, #self.historyPrefixIndex) == self.historyPrefixIndex then
                table.insert(filteredHistory, entry)
            end
        end
    else
        filteredHistory = self.history
    end

    if utf8.len(self.historyPrefixIndex) > 0
        and self.historyPrefixIndex ~= self.buffer:sub(1, #self.historyPrefixIndex) then
        self.historyPrefixIndex = self.buffer
        self.historyIndex = #filteredHistory
    else
        self.historyIndex = math.min(math.max(1, self.historyIndex + dt), #filteredHistory)
    end

    self.buffer = filteredHistory[self.historyIndex] or self.buffer
    self.currentPosition.x = utf8.len(self.buffer)

    self:renderHighlighted()
end

function LuaPrompt:renderHighlighted()
    self.tokens = {}

    self.highlightedBuffer = ""
    local lastIndex
    for kind, text, index in self.lexer:tokenize(self.buffer) do
        self.highlightedBuffer = self.highlightedBuffer
            .. (self.tokenColors[kind] or "")
            .. text
            .. colors.reset

        lastIndex = index

        table.insert(self.tokens, {
            kind = kind,
            index = index,
            text = text
        })
    end

    if lastIndex then
        self.highlightedBuffer = self.highlightedBuffer
            .. self.buffer:sub(lastIndex)
    end
end

function LuaPrompt:getCurrentToken()
    local currentToken
    for i, token in ipairs(self.tokens) do
        if token.index + utf8.len(token.text) >= self.currentPosition.x then
            break
        end

        currentToken = i
    end

    return currentToken
end

local keywords = {
    "and", "break", "do", "else", "elseif", "end",
    "false", "for", "function", "goto", "if", "in",
    "local", "nil", "not", "or", "repeat", "return",
    "then", "true", "until", "while"
}

function LuaPrompt:complete()
    local currentToken = self:getCurrentToken()

    if currentToken then
        currentToken = self.tokens[currentToken]
        local currentPart = self.buffer:sub(currentToken.index + #currentToken.text)

        local possibleValues = {}
        if self.tokens[currentToken - 1].text:match("[.:]")
            and self.tokens[currentToken - 2].kind == "identifier" then
            -- Explore identifier

        elseif self.tokens[currentToken].kind == "withespace" then
            -- Explore _G + keywords
            for _, k in ipairs(keywords) do
                if k:sub(1, #currentPart) == currentPart then
                    table.insert(possibleValues, k)
                end
            end

            for k, _ in pairs(_G) do
                if k:sub(1, #currentPart) == currentPart then
                    table.insert(possibleValues, k)
                end
            end
        end

    end
end

function LuaPrompt.validateLua(code)
    local fn, err = load("return " .. code, "croissant")
    if not fn then
        fn, err = load(code, "croissant")
    end

    return fn, (err and colors.red .. err .. colors.reset)
end

function LuaPrompt:processInput(input)
    Prompt.processInput(self, input)

    self:renderHighlighted()
end

function LuaPrompt:render()
    -- Swap with highlighted buffer for render
    local buffer = self.buffer
    self.buffer = self.highlightedBuffer

    Prompt.render(self)

    -- Restore buffer
    self.buffer = buffer
end

function LuaPrompt:processedResult()
    return self.buffer
end

return LuaPrompt