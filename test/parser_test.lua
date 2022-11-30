require "parser"
require "types"
require "test"

local function newparser(str)
    local reader = Reader:fromstring(str)
    local parser = Parser:new(reader)
    return parser
end

assert(newparser("42"):next() == 42)
assert(newparser("   42"):next() == 42)
assert(newparser("42  "):next() == 42)
assert(newparser("1 2 3"):next() == 1)

do
    local parser = newparser("1 2 3")
    assert(parser:next() == 1)
    assert(parser:next() == 2)
    assert(parser:next() == 3)
    assert(parser.reader:char() == nil)
end

do
    local result = newparser("foo"):next()
    assert(issymbol(result))
    assert(result.name == "foo")
end

assert(newparser("#t"):next() == true)
assert(newparser("#f"):next() == false)

assert_equal(newparser("()"):next(), List:null())
assert_equal(newparser("(1 2 3)"):next(), List:from { 1, 2, 3 })
assert_equal(newparser("(1 (2 3 ()) 4)"):next(), List:from { 1, List:from { 2, 3, List:null() }, 4 })

assert_equal(newparser("'a"):next(), Quote(Symbol "a"))
assert_equal(newparser("'()"):next(), Quote(List:null()))
assert_equal(newparser("'(1 2 3)"):next(), Quote(List:from { 1, 2, 3 }))
