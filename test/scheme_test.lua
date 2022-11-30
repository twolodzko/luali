require "scheme"
require "eval"
require "envir"
require "test"

local function evalstring(str)
    local env = Envir:new(scheme):branch()
    return eval.string(str, env)
end

assert_equal(evalstring("'()"), List:from {})
assert_equal(evalstring("#t"), true)
assert_equal(evalstring("#f"), false)

assert_equal(evalstring("(car '(1))"), 1)
assert_equal(evalstring("(car '(1 2 3))"), 1)

assert_equal(evalstring("(cdr '(1))"), List:null())
assert_equal(evalstring("(cdr '(1 2 3))"), List:from { 2, 3 })

assert_equal(evalstring("(cons 1 '(2 3))"), List:from { 1, 2, 3 })
assert_equal(evalstring("(cons 1 '())"), List:from { 1 })
assert_equal(evalstring("(cons '() '())"), List:from { List:null() })

assert_equal(evalstring("(list 1 2 3)"), List:from { 1, 2, 3 })
assert_equal(evalstring("(list)"), List:null())

assert_equal(evalstring("(quote x)"), Symbol "x")
assert_equal(evalstring("(quote (+ 2 2))"), List:from { Symbol "+", 2, 2 })

assert_equal(evalstring("(+)"), 0)
assert_equal(evalstring("(+ 5)"), 5)
assert_equal(evalstring("(+ 1 2 3)"), 6)
assert_equal(evalstring("(+ 1 (+ 5 6) 2)"), 14)

assert_equal(evalstring("(- 1)"), -1)
assert_equal(evalstring("(- 10 2 3)"), 5)

assert_equal(evalstring("(*)"), 1)
assert_equal(evalstring("(* 2)"), 2)
assert_equal(evalstring("(* 2 3 4)"), 24)

assert_equal(evalstring("(/ 2)"), 1 / 2)
assert_equal(evalstring("(/ 6 2)"), 3)
assert_equal(evalstring("(/ 24 4 3)"), 2)

assert_equal(evalstring("(=)"), true)
assert_equal(evalstring("(= 1)"), true)
assert_equal(evalstring("(= 2 (+ 1 1) (/ 4 2))"), true)
assert_equal(evalstring("(= 1 3)"), false)

assert_equal(evalstring("(< 1 2 3)"), true)
assert_equal(evalstring("(< 5 1 2 3)"), false)

assert_equal(evalstring("(> 3 2 1)"), true)
assert_equal(evalstring("(> 1 3 2)"), false)

assert_equal(evalstring("(equal? #f #f)"), true)
assert_equal(evalstring("(equal? #t #f)"), false)
assert_equal(evalstring("(equal? '() '())"), true)
assert_equal(evalstring("(equal? '(1 2 3) '(1 2 3))"), true)
assert_equal(evalstring("(equal? '(1 2 3) '(1 2))"), false)
assert_equal(evalstring("(equal? '(1 2) '(1 2 3))"), false)

assert_equal(evalstring("(begin (+ 10 100) (/ 4 2))"), 2)
assert_equal(evalstring("(begin (/ 4 2))"), 2)

assert_equal(evalstring("(eval '(+ 2 2))"), 4)

assert_equal(evalstring("(if #t 1 2)"), 1)
assert_equal(evalstring("(if #f 1 2)"), 2)
assert_equal(evalstring("(if #t 1)"), 1)
assert_equal(evalstring("(if (= 5 5) (+ 1 10) (+ 2 20))"), 11)
assert_equal(evalstring("(if (= 5 5) (+ 1 10) (error 'failed))"), 11)

assert_equal(evalstring("(cond (else 1))"), 1)
assert_equal(evalstring("(cond (#t 1))"), 1)
assert_equal(evalstring("(cond (#t 1) (#f 2))"), 1)
assert_equal(evalstring("(cond (#f 1) (#t 2))"), 2)
assert_equal(evalstring("(cond (#f 1) (else (+ 10 100)))"), 110)
assert_equal(evalstring("(cond (#f 1) (else))"), true)
assert_equal(evalstring("(cond (#t 1) (#f (error 'fail)))"), 1)
assert_equal(evalstring("(cond (#f (error 'fail)) (#t 2))"), 2)

assert_equal(evalstring("(not #t)"), false)
assert_equal(evalstring("(not #f)"), true)
assert_equal(evalstring("(not '())"), false)

assert_equal(evalstring("(and)"), true)
assert_equal(evalstring("(and #t #t)"), true)
assert_equal(evalstring("(and #f)"), false)
assert_equal(evalstring("(and #t #t #f)"), false)

assert_equal(evalstring("(or)"), false)
assert_equal(evalstring("(or #t #t)"), true)
assert_equal(evalstring("(or #f #t)"), true)
assert_equal(evalstring("(or #f #t #f)"), true)
assert_equal(evalstring("(or #f)"), false)
assert_equal(evalstring("(or #f #f)"), false)

assert_equal(evalstring("(number? 42)"), true)
assert_equal(evalstring("(number? 1e-5)"), true)
assert_equal(evalstring("(number? #t)"), false)
assert_equal(evalstring("(number? '())"), false)

assert_equal(evalstring("(string? \"\")"), true)
assert_equal(evalstring("(string? \"hello, world!\")"), true)
assert_equal(evalstring("(string? \"William Joseph \\\"Wild Bill\\\" [1] Donovan\")"), true)
assert_equal(evalstring("(string? #t)"), false)
assert_equal(evalstring("(string? '())"), false)

assert_equal(evalstring("(bool? #t)"), true)
assert_equal(evalstring("(bool? #f)"), true)
assert_equal(evalstring("(bool? 'foo)"), false)
assert_equal(evalstring("(bool? '())"), false)

assert_equal(evalstring("(symbol? 'bar)"), true)
assert_equal(evalstring("(symbol? 'car)"), true)
assert_equal(evalstring("(symbol? #t)"), false)
assert_equal(evalstring("(symbol? '())"), false)

assert_equal(evalstring("(procedure? car)"), true)
assert_equal(evalstring("(procedure? +)"), true)
assert_equal(evalstring("(procedure? #t)"), false)
assert_equal(evalstring("(procedure? '())"), false)

assert_equal(evalstring("(pair? '(1))"), true)
assert_equal(evalstring("(pair? '(1 2 3))"), true)
assert_equal(evalstring("(pair? '(()))"), true)
assert_equal(evalstring("(pair? '())"), false)
assert_equal(evalstring("(pair? #t)"), false)

assert_equal(evalstring("(null? '())"), true)
assert_equal(evalstring("(null? (list))"), true)
assert_equal(evalstring("(null? '(()))"), false)
assert_equal(evalstring("(null? '(#t))"), false)
assert_equal(evalstring("(null? #t)"), false)

assert_equal(evalstring("(car (cdr '(1 2 3)))"), 2)
assert_equal(evalstring("(= (cons 1 '(2 3)) (cdr (list 0 1 2 3)))"), true)

assert_equal(evalstring("(define x (+ 2 3))\n\nx"), 5)

do
    local env = Envir:new(scheme):branch()
    assert(not env.table or not env.table["x"])
    eval.string("(define x 42)", env)
    assert_equal(env:get("x"), 42)

    eval.string("(define x 'foo)", env)
    assert_equal(env:get("x"), Symbol "foo")
end

do
    local parent = Envir:new(scheme):branch()
    local child = parent:branch()

    eval.string("(define x 42)", child)
    assert(not parent.table or not parent.table["x"])
    assert(child.table["x"] == 42)
end

do
    local parent = Envir:new(scheme):branch({ x = 1 })
    local child = parent:branch()
    assert_equal(eval.string("x", child), 1)

    eval.string("(set! x (+ 11 11 10 10))", child)
    assert(parent.table["x"] == 42)
    assert(not child.table or not child.table["x"])
    assert_equal(eval.string("x", child), 42)
end

assert_equal(evalstring("(let () '())"), List:null())
assert_equal(evalstring("(let () (+ 2 2))"), 4)
assert_equal(evalstring("(let ((x 1)) (+ 2 x))"), 3)
assert_equal(evalstring("(let ((x 1) (y 2)) (+ x y))"), 3)
assert_equal(evalstring("(let ((x 1) (y (- 3 1))) (car '(1 2 3)) (+ x y))"), 3)
-- it's not let* so it would fail
assert(not pcall(evalstring, "(let ((x 1) (y (+ x 1))) (+ x y))"))
assert_equal(evalstring("(let ((x 1) (y 1)) (let ((x (* 10 x))) (+ x y)))"), 11)
assert_equal(evalstring("(let ((test #t)) (if test 1 2))"), 1)
assert_equal(evalstring("(let ((test #f)) (if test 1 2))"), 2)

assert_equal(evalstring("(let* () '())"), List:null())
assert_equal(evalstring("(let* () (+ 2 2))"), 4)
assert_equal(evalstring("(let* ((x 1)) (+ 2 x))"), 3)
assert_equal(evalstring("(let* ((x 1) (y 2)) (+ x y))"), 3)
assert_equal(evalstring("(let* ((x 1) (y (- 3 1))) (car '(1 2 3)) (+ x y))"), 3)
assert_equal(evalstring("(let* ((x 1) (y (+ x 1))) (+ x y))"), 3)

assert_equal(evalstring("((lambda (x) x) 42)"), 42)
assert_equal(evalstring("((lambda (x y) (+ x y)) 2 3)"), 5)
assert_equal(evalstring("((lambda (x) (let ((x (+ x 1))) (* x 2))) 1)"), 4)
assert_equal(evalstring("(((lambda (x) (lambda (y) (/ x y))) 1) 2)"), 0.5)

assert_equal(evalstring("(let ((x 2)) ((lambda (y) (+ y (+ x 1))) x))"), 5)
assert_equal(evalstring("((let ((x 2)) (lambda (y) (+ x y))) 3)"), 5)
assert_equal(evalstring("((let* ((x 1) (z (+ x 1))) (lambda (y) (+ x y z))) 3)"), 6)

assert(evalstring("(load \"examples/simple.scm\")"))
