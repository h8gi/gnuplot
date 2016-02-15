;;; plot.scm
(use gnuplot format)
(gp-debug #t)
(define gp (new-gp))
(define x-lst (iota 100 0 0.1))
(define y-lst (map sin x-lst))

(gp-plot-list gp x-lst y-lst
              #:title "sin"
              #:with "lines")

(gp-plot-list gp x-lst (reverse y-lst)
              #:replot #t)

(gp-plot-list gp x-lst (map (lambda (x) (* x x)) y-lst)
              #:replot #t
              #:with "lines")

;;; http://folk.uio.no/hpl/scripting/doc/gnuplot/Kawano/intro/plotcalc.html

(define (pade n)
  (let ([d 0.1]
        [z1 (lambda (x)
              (/ (- 6 (* 2 x))
                 (+ 6 (* 4 x) (* x x))))]
        [z2 (lambda (x)
              (/ (+ 6 (* -4 x) (* x x))
                 (+ 6 (* 2 x))))])
    (let loop ([n n]
               [x d])
      (unless (zero? n)
        (format #t "~6,2f ~11,4,2E ~11,4,2E ~11,4,2E~%" x (exp (- x)) (z1 x) (z2 x))
        (loop (sub1 n) (+ x d))))))

(with-output-to-file "pade.dat"
  (lambda ()
    (pade 50)))

(gp-plot-file gp "pade.dat"
              #:using '(1 2) #:with "lines"
              #:title "Analytical"
              #:main "Pade approximatioin"
              #:xlabel "x"
              #:ylabel "y=exp(-x)")

(gp-plot-file gp "pade.dat"
              #:using '(1 3) #:with "lines"
              #:replot #t
              #:title "L=1,M=2")

(gp-plot-file gp "pade.dat"
              #:using '(1 4) #:with "lines"
              #:replot #t
              #:title "L=2,M=1")

(gp-save-plot gp "pade.png")

(gp-kill gp)


