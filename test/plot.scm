;;; plot.scm
(use gnuplot)
(define gp (new-gp))
(define x-lst (iota 100 0 0.1))
(define y-lst (map sin x-lst))
(gp-plot gp x-lst y-lst)
