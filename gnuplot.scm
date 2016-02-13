;;; gnuplot.scm
(module gnuplot
    (export gp-debug new-gp gp-send-line
            gp-store-command gp-flush-command gp-show-command gp-reset-command
            gp-read-all gp-kill)
  (import scheme chicken posix ports srfi-13 data-structures)
  (include "main.scm"))
