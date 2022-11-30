function Symbol(name)
    local symbol = { type = "symbol", name = name }
    setmetatable(symbol, {
        __eq = function(x, y)
            return x.name == y.name
        end,
        __tostring = function(o)
            return o.name
        end
    })
    return symbol
end

function Quote(obj)
    local quote = { type = "quote", value = obj }
    setmetatable(quote, {
        __eq = function(x, y)
            return x.value == y.value
        end,
        __tostring = function(o)
            return string.format("'%s", o.value)
        end
    })
    return quote
end

List = {}

local function listtostring(list)
    local strs = {}
    while list.this ~= nil do
        table.insert(strs, tostring(list.this))
        list = list.next
    end
    return string.format("(%s)", table.concat(strs, " "))
end

local function listeq(x, y)
    while x.this ~= nil or y.this ~= nil do
        if x.this ~= y.this then
            return false
        end
        x, y = x.next, y.next
    end
    return true
end

function List:new()
    local list = { type = "list" }
    setmetatable(list, self)
    self.__index = self
    self.__eq = listeq
    self.__tostring = listtostring
    return list
end

function List:from(arr)
    local list = List:new()
    for i = #arr, 1, -1 do
        list = list:add(arr[i])
    end
    return list
end

function List:add(val)
    local list = List:new()
    list.this = val
    list.next = self
    return list
end

function List:null()
    return List:new()
end

function issymbol(obj)
    return type(obj) == "table" and obj.type == "symbol"
end

function isbool(obj)
    return type(obj) == "boolean"
end

function isnumber(obj)
    return type(obj) == "number"
end

function isstring(obj)
    return type(obj) == "string"
end

function islist(obj)
    return type(obj) == "table" and obj.type == "list"
end

function ispair(obj)
    return islist(obj) and obj.this ~= nil
end

function isnull(obj)
    return islist(obj) and obj.this == nil
end

function isquoted(obj)
    return type(obj) == "table" and obj.type == "quote"
end

function isprocedure(obj)
    return type(obj) == "function"
end
