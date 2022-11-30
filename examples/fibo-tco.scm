(define assert
    (lambda (cond)
        (if cond
            'ok
            (error 'assertion_error))))

(define fibo (lambda (n)
    (let* ((impl
            (lambda (it second first)
                (if (= it 0) first
                    (impl (- it 1)
                          (+ first second)
                          second)))))
        (impl n 1 0))))

(assert (= (fibo 0) 0))
(assert (= (fibo 1) 1))
(assert (= (fibo 2) 1))
(assert (= (fibo 3) 2))
(assert (= (fibo 7) 13))
(assert (= (fibo 9) 34))
(assert (= (fibo 10) 55))
(assert (= (fibo 20) 6765))
