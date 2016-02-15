(use srfi-18)
(define-record gp in out pid (setter cmd) (setter live?) (setter tmpfiles))
(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd x) (if (gp-live? x) "live" "dead")))

(define gp-debug (make-parameter #f))

(define (assert-live gp)
  (unless (gp-live? gp)
    (error "gp is already dead.")))

(define (new-gp)
  (receive (in out pid) (process "gnuplot 2>&1")
    (make-gp in out pid "" #t '())))

(define (gp-send-line gp . strs)
  (apply gp-store-command gp strs)
  (gp-flush-command gp)
  (thread-sleep! 0.01)                  ; wait gnuplot's error message (horrible)
  (display (gp-read-all gp)))

(define (gp-store-command gp . strs)
  (assert-live gp)
  (set! (gp-cmd gp)
        (conc (gp-cmd gp) " " (string-join (map ->string strs) " "))))

(define (gp-flush-command gp)  
  (assert-live gp)
  (display (gp-cmd gp) (gp-out gp))
  (when (gp-debug) (display "gnuplot>") (gp-show-command gp))
  (newline (gp-out gp))
  (flush-output (gp-out gp))
  (gp-reset-command gp))

(define (gp-show-command gp)
  (assert-live gp)
  (display (gp-cmd gp))
  (newline))

(define (gp-reset-command gp)
  (assert-live gp)
  (set! (gp-cmd gp) ""))

(define (gp-read-all gp)
  (with-output-to-string
      (lambda ()
        (let loop ()
          (when (gp-char-ready? gp)
            (display (read-char (gp-in gp)))
            (loop))))))

(define (gp-char-ready? gp)
  (assert-live gp)
  (char-ready? (gp-in gp)))

(define (gp-kill gp)
  (gp-store-command gp "quit")
  (gp-flush-command gp)
  (set! (gp-live? gp) #f)
  (for-each delete-file* (gp-tmpfiles gp))
  (display (conc "gp(" (gp-pid gp) ") is dead.\n")))

;;; plot 
(define (gp-plot-list gp x-lst y-lst
                      #!key title (with "linespoints") (replot #f)
                      main xlabel ylabel)
  (let ([tmpfile (create-temporary-file)])
    (set! (gp-tmpfiles gp) (cons tmpfile (gp-tmpfiles gp)))
    (with-output-to-file tmpfile
      (lambda ()
        (for-each (lambda (x y)
                    (display (conc x ", " y "\n")))
                  x-lst y-lst)))
    (when main
      (gp-set gp "title" (conc "'" main "'")))
    (when xlabel
      (gp-set gp "xlabel" (conc "'" xlabel "'")))
    (when ylabel
      (gp-set gp "ylabel" (conc "'" ylabel "'")))
    (gp-send-line gp
                  (conc (if replot "re" "") "plot '" tmpfile "'")
                  (if title (conc "title '" title "'") "")
                  (conc "with " with))))

(define (gp-plot-file gp datafile
                      #!key (using '(1 2)) title (with "linespoints") (replot #f)
                      main xlabel ylabel)
  (when main
    (gp-set gp "title" (conc "'" main "'")))
  (when xlabel
    (gp-set gp "xlabel" (conc "'" xlabel "'")))
  (when ylabel
    (gp-set gp "ylabel" (conc "'" ylabel "'")))
  (gp-send-line gp
                (conc (if replot "re" "") "plot '" datafile "'")
                (conc "using " (string-join (map ->string using) ":"))
                (if title (conc "title '" title "'") "")
                (conc "with " with)))

(define (gp-set gp key value)
  (gp-send-line gp (conc "set " key " " value)))

(define term-alist
  '(("png" . "png")
    ("gif" . "gif")
    ("jpg" . "jpeg")
    ("jpeg" . "jpeg")
    ("svg" . "svg")
    ("eps" . "postscript eps enhanced color")))

(define (gp-save-plot gp filename)
  (cond [(assoc (last (string-split filename "."))
                term-alist)
         =>
         (lambda (p)
           (gp-send-line gp (conc "set terminal " (cdr p)))
           (gp-send-line gp (conc "set output '" filename "'"))
           (gp-send-line gp "replot")
           (gp-send-line gp "set terminal pop")
           (gp-send-line gp "set output"))]))
