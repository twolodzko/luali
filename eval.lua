require "types"
require "parser"

local function evallist(list, env)
    local fun = eval.sexpr(list.this, env)
    local args = list.next
    return fun(args, env)
end

eval = {}

function eval.sexpr(sexpr, env)
    if isquoted(sexpr) then
        return sexpr.value
    elseif issymbol(sexpr) then
        return env:get(sexpr.name)
    elseif islist(sexpr) then
        return evallist(sexpr, env)
    else
        return sexpr
    end
end

function eval.each(list, env)
    local current = List:null()
    local out = current
    local last
    while list.this ~= nil do
        last = eval.sexpr(list.this, env)
        current.this = last
        current.next = List:null()
        current = current.next
        list = list.next
    end
    return out, last
end

function eval.stream(parser, env)
    local sexpr, last
    while true do
        sexpr = parser:next()
        if sexpr == nil then
            break
        end
        last = eval.sexpr(sexpr, env)
    end
    return last
end

function eval.string(str, env)
    local reader = Reader:fromstring(str)
    local parser = Parser:new(reader)
    return eval.stream(parser, env)
end

function eval.file(filename, env)
    local reader = Reader:fromfile(filename)
    local parser = Parser:new(reader)
    return eval.stream(parser, env)
end

return eval
