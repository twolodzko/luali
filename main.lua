#!/usr/bin/env lua

require "envir"
require "eval"
require "reader"
require "scheme"

local function repl(env)
    print(string.format("Press ^D to exit (using %s)\n", _VERSION))

    local reader = StdInReader:new()
    local parser = Parser:new(reader)
    local sexpr, result

    while true do
        sexpr = parser:next()
        result = eval.sexpr(sexpr, env)
        print(result)
    end
end

do
    local env = Envir:new(scheme):branch()

    if #arg == 0 then
        repl(env)
    else
        for _, filename in ipairs(arg) do
            eval.file(filename, env)
        end
    end
end
