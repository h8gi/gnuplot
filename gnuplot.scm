;;; gnuplot.scm
(module gnuplot
    (gp-debug new-gp gp-send!
              gp-store-command gp-flush-command gp-show-command gp-reset-command
              gp-read-all gp-kill)
  (import scheme chicken posix ports srfi-13 data-structures miscmacros)
  (use srfi-18)
  (include "main.scm")
  )
