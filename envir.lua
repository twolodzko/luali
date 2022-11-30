Envir = {}

function Envir:new(records, parent)
    local env = { table = records, parent = parent }
    setmetatable(env, self)
    self.__index = self
    return env
end

function Envir:branch(records)
    return Envir:new(records, self)
end

function Envir:get(key)
    if self.table and self.table[key] ~= nil then
        return self.table[key]
    elseif self.parent then
        return self.parent:get(key)
    else
        error(string.format("unbound variable %s", key))
    end
end

function Envir:define(key, val)
    if not self.table then
        self.table = {}
    end
    self.table[key] = val
end

function Envir:set(key, val)
    if self.table and self.table[key] ~= nil then
        self.table[key] = val
    elseif self.parent then
        self.parent:set(key, val)
    else
        error(string.format("unbound variable %s", key))
    end
end

return Envir
