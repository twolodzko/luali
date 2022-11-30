require "envir"

do
    local env = Envir:new({ x = 1, y = 2 })
    assert(env:get("x") == 1)

    assert(not env.table["z"])
    env:define("z", 3)
    assert(env:get("z") == 3)
end

do
    local env = Envir:new()
    assert(not env.table)
    env:define("abc", 42)
    assert(env:get("abc") == 42)
end

do
    local parent = Envir:new({ x = 1, y = 2 })
    local child = parent:branch({ z = 3 })

    assert(parent:get("x") == 1)
    assert(not parent.table["z"])

    assert(child:get("x") == 1)
    assert(child:get("z") == 3)
end

do
    local parent = Envir:new({ x = 1, y = 2 })
    local child = parent:branch()

    assert(parent:get("x") == 1)
    assert(child:get("x") == 1)

    assert(not parent.table["z"])
    assert(not child.table or not child.table["z"])

    child:define("z", 3)
    assert(not parent.table["z"])
    assert(child.table["z"] == 3)
end

do
    local parent = Envir:new({ x = 1, y = 2 })
    local child = parent:branch({ z = 3 })

    assert(not parent.table["z"])
    assert(child.table["z"] == 3)
    child:set("z", 300)
    assert(not parent.table["z"])
    assert(child.table["z"] == 300)

    assert(parent:get("x") == 1)
    assert(child:get("x") == 1)
    assert(not child.table["x"])

    child:set("x", 100)
    assert(parent:get("x") == 100)
    assert(child:get("x") == 100)
    assert(not child.table["x"])
end
