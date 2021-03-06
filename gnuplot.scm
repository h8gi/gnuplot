;;; gnuplot.scm
(module gnuplot
	(export gp-debug gp-send-line
		gp-store-command gp-flush-command gp-show-command gp-reset-command
		gp-read-all gp-start gp-kill
		gp-plot-list gp-plot-file gp-save-plot
		gp-set)
	(import scheme chicken posix ports srfi-1 srfi-13 data-structures files)
	(include "main.scm"))
