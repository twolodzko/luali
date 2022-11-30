Reader = {}

function Reader:new()
    local reader = { pos = 1, cache = "" }
    setmetatable(reader, self)
    self.__index = self
    return reader
end

function Reader:fromstring(str)
    local reader = Reader:new()
    reader.cache = str
    return reader
end

function Reader:fromfile(filename)
    local f = assert(io.open(filename, "r"))
    local str = f:read("*all")
    f:close()
    return Reader:fromstring(str)
end

function Reader:char()
    local char = self.cache:sub(self.pos, self.pos)
    if char == "" then
        return nil
    end
    return char
end

function Reader:next()
    self.pos = self.pos + 1
end

StdInReader = Reader:new()

function StdInReader:new()
    self:next()
    return self
end

function StdInReader:next()
    self.pos = self.pos + 1
    if self.pos > #self.cache then
        io.write("> ")
        self.cache = io.read() .. "\n"
        self.pos = 1
    end
end
