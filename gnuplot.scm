;;; gnuplot.scm
(module gnuplot
    (start-gnuplot g-enter g-write g-quit g-read g-command g-erase plot-list)
  (import scheme chicken posix extras srfi-1 files)
  (include "main.scm")
  )
