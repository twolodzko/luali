require "eval"
require "types"

-- See: http://www.lua.org/pil/13.4.5.html
local function readonly(tab)
    return setmetatable({}, {
        __index = tab,
        __newindex = function(tab, key, value)
            error("attempt to modify a read-only table")
        end,
        __metatable = false
    })
end

local function compareusing(fun)
    return function(args, env)
        if args.next == nil then
            return true
        end

        local prev, current
        prev = eval.sexpr(args.this, env)
        args = args.next

        while args.this ~= nil do
            current = eval.sexpr(args.this, env)
            if not fun(prev, current) then
                return false
            end
            prev = current
            args = args.next
        end
        return true
    end
end

local function simplefun(fun)
    return function(args, env)
        return fun(eval.sexpr(args.this, env))
    end
end

local function initlambda(vars, args, evalenv, saveenv)
    local key, val
    while vars.this ~= nil and args.this ~= nil do
        key = vars.this
        val = args.this
        if not issymbol(key) then
            error(string.format("%s is not a symbol", key))
        end
        saveenv:define(key.name, eval.sexpr(val, evalenv))
        vars, args = vars.next, args.next
    end
    return saveenv
end

local function initlet(bindings, evalenv, saveenv)
    local key, val
    while bindings.this ~= nil do
        key = bindings.this.this
        val = bindings.this.next.this
        if not issymbol(key) then
            error(string.format("%s is not a symbol", key))
        end
        saveenv:define(key.name, eval.sexpr(val, evalenv))
        bindings = bindings.next
    end
    return saveenv
end

local procedures = {}

procedures["lambda"] = function(args, env)
    local vars = args.this
    local body = args.next
    return function(callargs, callenv)
        local localenv = env:branch()
        initlambda(vars, callargs, callenv, localenv)
        local _, result = eval.each(body, localenv)
        return result
    end
end

procedures["let"] = function(args, env)
    local bindings = args.this
    local body = args.next

    local localenv = env:branch()
    initlet(bindings, env, localenv)

    local _, result = eval.each(body, localenv)
    return result
end

procedures["let*"] = function(args, env)
    local bindings = args.this
    local body = args.next

    local localenv = env:branch()
    initlet(bindings, localenv, localenv)

    local _, result = eval.each(body, localenv)
    return result
end

procedures["define"] = function(args, env)
    local key = args.this
    if not issymbol(key) then
        error(string.format("%s is not a symbol", key))
    end
    local val = eval.sexpr(args.next.this, env)
    env:define(key.name, val)
end

procedures["set!"] = function(args, env)
    local key = args.this
    if not issymbol(key) then
        error(string.format("%s is not a symbol", key))
    end
    local val = eval.sexpr(args.next.this, env)
    env:set(key.name, val)
end

procedures["car"] = function(args, env)
    local list = eval.sexpr(args.this, env)
    return list.this
end

procedures["cdr"] = function(args, env)
    local list = eval.sexpr(args.this, env)
    return list.next
end

procedures["cons"] = function(args, env)
    local val = args.this
    local list = args.next.this
    val = eval.sexpr(val, env)
    list = eval.sexpr(list, env)
    return list:add(val)
end

procedures["list"] = function(args, env)
    local list, _ = eval.each(args, env)
    return list
end

procedures["quote"] = function(args)
    return args.this
end

procedures["begin"] = function(args, env)
    local _, last = eval.each(args, env)
    return last
end

procedures["eval"] = function(args, env)
    return eval.sexpr(eval.sexpr(args.this, env), env)
end

procedures["if"] = function(args, env)
    local iftrue = args.next.this
    local iffalse = args.next.next.this
    if eval.sexpr(args.this, env) then
        return eval.sexpr(iftrue, env)
    else
        return eval.sexpr(iffalse, env)
    end
end

procedures["cond"] = function(args, env)
    local condition, body
    while args.this ~= nil do
        condition = args.this.this
        body = args.this.next
        if eval.sexpr(condition, env) then
            if body.this ~= nil then
                local _, last = eval.each(body, env)
                return last
            else
                return true
            end
        end
        args = args.next
    end
end

procedures["else"] = true

procedures["not"] = function(args, env)
    return not eval.sexpr(args.this, env)
end

procedures["and"] = function(args, env)
    while args.this ~= nil do
        if not eval.sexpr(args.this, env) then
            return false
        end
        args = args.next
    end
    return true
end

procedures["or"] = function(args, env)
    while args.this ~= nil do
        if eval.sexpr(args.this, env) then
            return true
        end
        args = args.next
    end
    return false
end

procedures["+"] = function(args, env)
    local acc = 0
    while args.this ~= nil do
        acc  = acc + eval.sexpr(args.this, env)
        args = args.next
    end
    return acc
end

procedures["-"] = function(args, env)
    local acc = eval.sexpr(args.this, env)
    args = args.next

    if args.this == nil then
        return -acc
    end
    repeat
        acc  = acc - eval.sexpr(args.this, env)
        args = args.next
    until args.this == nil
    return acc
end

procedures["*"] = function(args, env)
    local acc = 1
    while args.this ~= nil do
        acc  = acc * eval.sexpr(args.this, env)
        args = args.next
    end
    return acc
end

procedures["/"] = function(args, env)
    local acc = eval.sexpr(args.this, env)
    args = args.next

    if args.this == nil then
        return 1 / acc
    end
    repeat
        acc  = acc / eval.sexpr(args.this, env)
        args = args.next
    until args.this == nil
    return acc
end

procedures["equal?"] = function(args, env)
    local x = eval.sexpr(args.this, env)
    local y = eval.sexpr(args.next.this, env)
    return x == y
end

procedures["eq?"] = procedures["equal?"]

procedures["="] = compareusing(function(x, y) return x == y end)

procedures["<"] = compareusing(function(x, y) return x < y end)

procedures[">"] = compareusing(function(x, y) return x > y end)

procedures["number?"] = simplefun(isnumber)

procedures["string?"] = simplefun(isstring)

procedures["bool?"] = simplefun(isbool)

procedures["symbol?"] = simplefun(issymbol)

procedures["pair?"] = simplefun(ispair)

procedures["null?"] = simplefun(isnull)

procedures["procedure?"] = simplefun(isprocedure)

procedures["error"] = function(args, env)
    local msg = eval.sexpr(args.this, env)
    error(msg)
end

procedures["display"] = function(args, env)
    local msg = eval.sexpr(args.this, env)
    print(msg)
end

procedures["load"] = function(args, env)
    return eval.file(args.this, env)
end

procedures["true"] = true

procedures["false"] = false

scheme = readonly(procedures)
return scheme
