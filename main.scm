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
  (when (gp-debug) (display (gp-cmd gp)))
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

(define (gp-plot gp x-lst y-lst #!key title (with "linespoints"))
  (gp-send-line gp (conc "plot '-' "
                     (when title (conc "title \"" title "\""))
                     (when with  (conc "with " with))))
  (for-each (lambda (x y)
              (gp-send-line gp (conc x ", " y)))
            x-lst y-lst)
  (gp-send-line gp "e"))
