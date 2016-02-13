;;; gnuplot.scm
(module gnuplot
    (export gp-debug new-gp gp-send-line
            gp-store-command gp-flush-command gp-show-command gp-reset-command
            gp-read-all gp-kill
            gp-plot-list gp-plot-file)
  (import scheme chicken posix ports srfi-13 data-structures files)
  (include "main.scm"))
