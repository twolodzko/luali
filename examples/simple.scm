(define assert
    (lambda (cond)
        (if cond
            'ok
            (error 'assertion_error))))

(define x2
    (lambda (x)
        (+ x x)))

(assert
    (let ((x 1) (y 2))
        (= (x2 x) y)))

(define len
    (lambda (lst)
        (if (null? lst)
            0
            (+ 1 (len (cdr lst))))))

(assert (= 0 (len '())))
(assert (= 1 (len '(42))))
(assert (= 3 (len '(1 2 3))))
