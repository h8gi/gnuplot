(use srfi-18)
(define gp)
(define-record gp in out pid (setter cmd) (setter live?))
(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd gp) (if (gp-live? gp) "live" "dead")))

(define gp-debug (make-parameter #f))

(define (assert-live gp)
  (unless (gp-live? gp)
    (error "gp is already dead.")))

(define (new-gp)
  (receive (in out pid) (process "gnuplot 2>&1")
    (make-gp in out pid "" #t)))

(define (gp-send! gp . strs)
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
        (while (gp-char-ready? gp)
          (display (read-char (gp-in gp)))))))

(define (gp-char-ready? gp)
  (assert-live gp)
  (char-ready? (gp-in gp)))

(define (gp-kill gp)
  (assert-live gp)
  (gp-store-command gp "quit")
  (gp-flush-command gp)
  (set! (gp-live? gp) #f)
  (display (conc "gp(" (gp-pid gp) ") is dead.\n")))
