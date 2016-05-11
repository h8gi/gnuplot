(use srfi-18)
(define-record gp
  in
  out
  pid
  (setter cmd)
  (setter live?)
  (setter tmpfiles))

(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd x) (if (gp-live? x) "live" "dead")))

(define *gp* #f)

(define (gp-start)
  (unless (and *gp* (gp-live? *gp*))
    (receive (in out pid) (process "gnuplot 2>&1")
      (set! *gp* (make-gp in out pid "" #t '())))))

(define (gp-kill)
  (gp-store-command "quit")
  (gp-flush-command)
  (set! (gp-live? *gp*) #f)
  (for-each delete-file* (gp-tmpfiles *gp*))
  (close-input-port (gp-in *gp*))
  (close-output-port (gp-out *gp*))
  (display (conc "gp(" (gp-pid *gp*) ") is dead.\n")))

(define gp-debug (make-parameter #f))

(define (assert-live)
  (unless (and *gp* (gp-live? *gp*))
    (error "gp is already dead.")))

(define (gp-send-line . strs)
  (apply gp-store-command strs)
  (gp-flush-command)
  (thread-sleep! 0.01)                  ; wait gnuplot's error message (horrible)
  (display (gp-read-all)))

(define (gp-store-command . strs)
  (assert-live)
  (set! (gp-cmd *gp*)
        (conc (gp-cmd *gp*) " " (string-join (map ->string strs) " "))))

(define (gp-flush-command)  
  (assert-live)
  (display (gp-cmd *gp*) (gp-out *gp*))
  (when (gp-debug) (display "gnuplot>") (gp-show-command))
  (newline (gp-out *gp*))
  (flush-output (gp-out *gp*))
  (gp-reset-command))

(define (gp-show-command)
  (assert-live)
  (display (gp-cmd *gp*))
  (newline))

(define (gp-reset-command)
  (assert-live)
  (set! (gp-cmd *gp*) ""))

(define (gp-read-all)
  (with-output-to-string
      (lambda ()
        (let loop ()
          (when (gp-char-ready?)
            (display (read-char (gp-in *gp*)))
            (loop))))))

(define (gp-char-ready?)
  (assert-live)
  (char-ready? (gp-in *gp*)))

;;; plot 
(define (gp-plot-list x-lst y-lst
                      #!key title (with "linespoints") (replot #f)
                      main xlabel ylabel)
  (let* ([tmpfile (create-temporary-file)])
    (set! (gp-tmpfiles *gp*)
	  (cons tmpfile (gp-tmpfiles *gp*)))
    (with-output-to-file tmpfile
      (lambda ()
        (for-each (lambda (x y)
                    (display (conc x ", " y "\n")))
                  x-lst y-lst)))
    (when main
      (gp-set "title" (conc "'" main "'")))
    (when xlabel
      (gp-set "xlabel" (conc "'" xlabel "'")))
    (when ylabel
      (gp-set "ylabel" (conc "'" ylabel "'")))
    (gp-send-line 
     (conc (if replot "re" "") "plot '" tmpfile "'")
     (if title (conc "title '" title "'") "")
     (conc "with " with))))

(define (gp-plot-file datafile
                      #!key (using '(1 2)) title (with "linespoints") (replot #f)
                      main xlabel ylabel)
  (when main
    (gp-set "title" (conc "'" main "'")))
  (when xlabel
    (gp-set "xlabel" (conc "'" xlabel "'")))
  (when ylabel
    (gp-set "ylabel" (conc "'" ylabel "'")))
  (gp-send-line 
   (conc (if replot "re" "") "plot '" datafile "'")
   (conc "using " (string-join (map ->string using) ":"))
   (if title (conc "title '" title "'") "")
   (conc "with " with)))

(define (gp-set key value)
  (gp-send-line (conc "set " key " " value)))

(define term-alist
  '(("png" . "png")
    ("gif" . "gif")
    ("jpg" . "jpeg")
    ("jpeg" . "jpeg")
    ("svg" . "svg")
    ("eps" . "postscript eps enhanced color")))

(define (gp-save-plot filename)
  (cond [(assoc (last (string-split filename "."))
                term-alist)
         =>
         (lambda (p)
           (gp-send-line (conc "set terminal " (cdr p)))
           (gp-send-line (conc "set output '" filename "'"))
           (gp-send-line "replot")
           (gp-send-line "set terminal pop")
           (gp-send-line "set output"))]
        [else (error (conc "'" last "' is not supported"))]))
