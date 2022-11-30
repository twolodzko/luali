require "types"
require "reader"

-- See: http://www.lua.org/pil/11.5.html
local function Set(list)
    local set = {}
    for _, l in ipairs(list) do
        set[l] = true
    end
    return set
end

local whitespace = Set { " ", "\t", "\n", "\r" }
local wordend = Set { "(", ")", "'", ",", ";", "\"" }

local function readword(reader)
    local out = ""
    while reader:char() do
        local char = reader:char()
        if whitespace[char] or wordend[char] then
            break
        end
        out = out .. char
        reader:next()
    end
    return out
end

local function skipwhitespace(reader)
    while whitespace[reader:char()] do
        reader:next()
    end
end

local function skipline(reader)
    while reader:char() and reader:char() ~= "\n" do
        reader:next()
    end
end

local function readstring(reader)
    local out = ""
    while reader:char() do
        if reader:char() == "\"" then
            reader:next()
            return out
        elseif reader:char() == "\\" then
            reader:next()
        end
        out = out .. reader:char()
        reader:next()
    end
    return out
end

local function readlist(parser)
    local list = {}
    while parser.reader:char() do
        skipwhitespace(parser.reader)
        if parser.reader:char() == ")" then
            parser.reader:next()
            return List:from(list)
        end
        table.insert(list, parser:next())
    end
    error("missing )")
end

local function parseword(word)
    if word == "#t" then
        return true
    elseif word == "#f" then
        return false
    end
    return tonumber(word) or Symbol(word)
end

Parser = {}

function Parser:new(reader)
    local parser = { reader = reader }
    setmetatable(parser, self)
    self.__index = self
    return parser
end

function Parser:next()
    skipwhitespace(self.reader)
    local char = self.reader:char()
    if char == nil then
        return nil
    elseif char == ";" then
        skipline(self.reader)
        return self:next()
    elseif char == "(" then
        self.reader:next()
        return readlist(self)
    elseif char == ")" then
        error("unexpected )")
    elseif char == "," then
        error(", is not supported")
    elseif char == "'" then
        self.reader:next()
        return Quote(self:next())
    elseif char == "\"" then
        self.reader:next()
        return readstring(self.reader)
    end
    return parseword(readword(self.reader))
end

return Parser
