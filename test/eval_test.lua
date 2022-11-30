require "eval"
require "types"
require "envir"
require "scheme"
require "test"

assert_equal(eval.sexpr(5), 5)
assert_equal(eval.sexpr(Quote(Symbol "x")), Symbol "x")
assert_equal(eval.sexpr(Symbol "x", Envir:new({ x = 42 })), 42)
assert_equal(eval.sexpr(Quote(List:null())), List:null())

assert_equal(eval.each(List:null()), List:null())
assert_equal(eval.each(List:from { 1, 2, 3 }), List:from { 1, 2, 3 })
assert_equal(eval.each(List:from { Symbol "a", Symbol "b", Symbol "c" }, Envir:new({ a = 1, b = 2, c = 3 })),
    List:from { 1, 2, 3 })

do
    local result, last = eval.each(List:from { 1, 2, 3 })
    assert_equal(result, List:from { 1, 2, 3 })
    assert_equal(last, 3)
end

assert_equal(eval.sexpr(List:from { Symbol "add", 2, 3 },
    Envir:new({ add = function(args) return args.this + args.next.this end })), 5)

assert_equal(eval.string("(add 2 3)",
    Envir:new({ add = function(args) return args.this + args.next.this end })), 5)
