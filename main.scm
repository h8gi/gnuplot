(use srfi-18)
(define-record gp in out pid (setter cmd) (setter live?))
(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd x) (if (gp-live? x) "live" "dead")))

(define gp-debug (make-parameter #f))

(define (assert-live gp)
  (unless (gp-live? gp)
    (error "gp is already dead.")))

(define (new-gp)
  (receive (in out pid) (process "gnuplot 2>&1")
    (make-gp in out pid "" #t)))

(define (gp-send-line gp . strs)
  (apply gp-store-command gp strs)
  (gp-flush-command gp)
  (thread-sleep! 0.01)                  ; wait gnuplot's error message (horrible)
  (display (gp-read-all gp)))

(define (gp-store-command gp . strs)
  (assert-live gp)
  (set! (gp-cmd gp)
        (conc (gp-cmd gp) " " (string-join strs " "))))

(define (gp-flush-command gp)  
  (assert-live gp)
  (display (gp-cmd gp) (gp-out gp))
  (when (gp-debug) (gp-show-command gp))
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
  (display (conc "gp(" (gp-pid gp) ") is dead.\n")))

;;; plot 

(define (gp-plot-list gp x-lst y-lst
                      #!key title (with "linespoints") (replot #f))
  (gp-send-line gp
                (conc (if replot "re" "") "plot '-' ")
                (if title (conc "title '" title "'") "")
                (conc "with " with))
  (for-each (lambda (x y)
              (gp-send-line gp (conc x ", " y)))
            x-lst y-lst)
  (gp-send-line gp "e"))

(define (gp-plot-list gp x-lst y-lst
                      #!key title (with "linespoints") (replot #f))
  (let ([tmpfile (create-temporary-file)])
    (with-output-to-file tmpfile
      (lambda ()
        (for-each (lambda (x y)
                    (display (conc x ", " y "\n")))
                  x-lst y-lst)))
    (gp-send-line gp
                  (conc (if replot "re" "") "plot '" tmpfile "'")
                  (if title (conc "title '" title "'") "")
                  (conc "with " with))))

(define (gp-plot-file gp datafile
                      #!key (using '(1 2)) title (with "linespoints") (replot #f))
  (gp-send-line gp
                (conc (if replot "re" "") "plot '" datafile "'")
                (conc "using " (string-join (map ->string using) ":"))
                (if title (conc "title '" title "'"))
                (conc "with " with)))
