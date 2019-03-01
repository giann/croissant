local lpeg = require "lpeg"
local P    = lpeg.P
local R    = lpeg.R
local S    = lpeg.S
local D    = R"09"
local I    = R("AZ", "az", "\127\255") + "_"
local B    = -(I + D) -- word boundary

local Class = require "hump.class"

local function merge(t1, t2)
    local t = {}

    for k, v in pairs(t1) do
        t[k] = v
    end

    for k, v in pairs(t2) do
        t[k] = v
    end

    return t
end

local Lexer = Class {

    init = function (self, builtins)
        builtins = merge(
            require "croissant.builtins",
            builtins or {}
        )

        -- Adapted version of http://peterodding.com/code/lua/lxsh/ for Lua 5.3 syntax
        self.patterns = {}

        self.patterns.whitespace = S"\r\n\f\t\v "^1
        self.patterns.constant   = (P"true" + "false" + "nil") * B

        -- Strings
        local longstring = #(P"[[" + (P"[" * P"="^0 * "[")) * P(function(input, index)
            local level = input:match("^%[(=*)%[", index)
            if level then
                local _, last = input:find("]" .. level .. "]", index, true)
                if last then
                    return last + 1
                end
            end
        end)
        local singlequoted = P"'" * ((1 - S"'\r\n\f\\") + (P'\\' * 1))^0 * "'"
        local doublequoted = P'"' * ((1 - S'"\r\n\f\\') + (P'\\' * 1))^0 * '"'
        self.patterns.string = longstring + singlequoted + doublequoted

        -- Comments
        local eol        = P"\r\n" + "\n"
        local line       = (1 - S"\r\n\f")^0 * eol^-1
        local soi        = P(function(_, i)
            return i == 1 and i
        end)
        local shebang    = soi * "#!" * line
        local singleline = P"--" * line
        local multiline  = P"--" * longstring
        self.patterns.comment = multiline + singleline + shebang

        -- Numbers
        local sign        = S"+-"^-1
        local decimal     = D^1
        local hexadecimal = P"0" * S"xX" * R("09", "AF", "af") ^ 1
        local float       = D^1 * P"." * D^0 + P"." * D^1
        local maybeexp    = (float + decimal) * (S"eE" * sign * D^1)^-1
        self.patterns.number = hexadecimal + maybeexp

        -- Operators
        self.patterns.operator =
            (P"not" + "..." + "and" + ".." + "~="
                + "==" + ">=" + "<=" + "or"
                + ">>" + "<<" + (P"/" * P"/"^-1)
                + S"]{=>^[<;)*(%}+-:,.#&~|")

        -- Keywords
        self.patterns.keywords =
            (P"and"     + "break" + "do"       + "else" + "elseif" + "end"
              + "false" + "for"   + "function" + "goto" + "if"     + "in"
              + "local" + "nil"   + "not"      + "or"   + "repeat" + "return"
              + "then"  + "true"  + "until"    + "while") * B

        -- Identifiers
        local ident = I * (I + D)^0
        local expr = ('.' * ident)^0
        self.patterns.identifier = lpeg.Cmt(
            ident,
            function(input, index)
                return expr:match(input, index)
            end
        )

        -- Builtins
        if #builtins > 0 then
            self.patterns.builtin = P(builtins[1])
            for i = 2, #builtins do
                self.patterns.builtin = self.patterns.builtin + builtins[i]
            end
            self.patterns.builtin = self.patterns.builtin * B

            table.insert(self.patterns, "builtin")
        end

        table.insert(self.patterns, "whitespace")
        table.insert(self.patterns, "constant")
        table.insert(self.patterns, "string")
        table.insert(self.patterns, "comment")
        table.insert(self.patterns, "number")
        table.insert(self.patterns, "operator")
        table.insert(self.patterns, "keywords")
        table.insert(self.patterns, "identifier")

        self:compile()
    end

}

function Lexer:compile()
    local function id(n)
        return lpeg.Cc(n) * self.patterns[n] * lpeg.Cp()
    end

    local any = id(self.patterns[1])
    for i = 2, #self.patterns do
        any = any + id(self.patterns[i])
    end

    self.any = any
end

function Lexer.sync(token, lnum, cnum)
    local lastidx

    lnum, cnum = lnum or 1, cnum or 1
    if token:find "\n" then
        for i in token:gmatch "()\n" do
            lnum = lnum + 1
            lastidx = i
        end
        cnum = #token - lastidx + 1
    else
        cnum = cnum + #token
    end

    return lnum, cnum
end

function Lexer:tokenize(subject)
    local index, lnum, cnum = 1, 1, 1
    return function()
        local kind, after = self.any:match(subject, index)
        if kind and after then
            local text = subject:sub(index, after - 1)
            local oldlnum, oldcnum = lnum, cnum
            index = after
            lnum, cnum = Lexer.sync(text, lnum, cnum)
            return kind, text, index, oldlnum, oldcnum
        end
    end
end

return Lexer
