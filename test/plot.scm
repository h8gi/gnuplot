;;; plot.scm
(use gnuplot)
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

; (gp-kill gp)
