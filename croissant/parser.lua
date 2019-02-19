local Class = require "hump.class"

local Parser = Class {

    nodes = {
        chunk = 1,

    },

    init = function(self, tokens)
        self.tokens = tokens
        self.currentToken = 1
    end

}

function Parser:parse()
    self:statlist()
end

function Parser:statlist()
    while (not self:block_follow(true)) do
        local token = self.tokens[self.currentToken]

        if token.kind == "keyword"
            and token.text == "return" then
            self:statement()
            return
        end

        self:statement()
    end
end

function Parser:block_follow()

end

function Parser:statement()
    local kind, text =
        self.tokens[self.currentToken].kind,
            self.tokens[self.currentToken].text

    if text == ";" then
        self.currentToken = self.currentToken + 1
    elseif kind == "keyword"
        and text == "if" then
        self:ifstat()
    elseif kind == "keyword"
        and text == "while" then
        self:whilestat()
    elseif kind == "keyword"
        and text == "do" then
        self:block()
        self:checkmatch("keyword", "end", "keyword", "do")
    elseif kind == "keyword"
        and text == "for" then
        self:forstat()
    elseif kind == "keyword"
        and text == "repeat" then
        self:repeatstat()
    elseif kind == "keyword"
        and text == "function" then
        self:funcstat()
    elseif kind == "keyword"
        and text == "local" then
        self.currentToken = self.currentToken + 1
        if self:testnext("keyword", "function") then
            self:localfunc()
        else
            self:localstat()
        end
    elseif kind == "operator"
        and text == ":" then
        self.currentToken = self.currentToken + 1
        self:labelstat()
    elseif kind == "keyword"
        and text == "return" then
        self.currentToken = self.currentToken + 1
        self:retstat()
    elseif kind == "keyword"
        and (text == "break"
            or text == "goto") then
        self:gotostat()
    else
        self:exprstat()
    end
end

function Parser:checkmatch()
end

function Parser:ifstat()
end

function Parser:whilestat()
end

function Parser:block()
end

function Parser:forstat()
end

function Parser:repeatstat()
end

function Parser:funcstat()
end

function Parser:testnext()
end

function Parser:localfunc()
end

function Parser:localstat()
end

function Parser:labelstat()
end

function Parser:retstat()
end

function Parser:gotostat()
end

function Parser:exprstat()
end


return Parser