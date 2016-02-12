(use posix miscmacros)
(define-record gp in out pid (setter cmd) (setter live?) (setter bg-pid))
(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd gp) (if (gp-live? gp) "live" "dead")))

(define debug (make-parameter #f))
(define (dbg-call str)
  (when (debug) (display (conc str "\n") (current-error-port))))

(define (assert-live gp)
  (unless (gp-live? gp)
    (error "gp is already dead.")))

(define (gp-error-handler gp)
  (let loop ()
    (when (gp-live? gp)
      (display (gp-read gp) (current-error-port))
      (flush-output (current-error-port))
      (loop))))

(define (new-gp)
  (receive (in out pid) (process "gnuplot 2>&1")
    (let ([gp (make-gp in out pid "" #t 0)])
      (set! (gp-bg-pid gp) (process-fork
                            (lambda ()
                              (gp-error-handler gp))))
      gp)))

(define (gp-read gp)
  (assert-live gp)
  (read-line (gp-in gp)))

(define (gp-send! gp . strs)
  (apply gp-store-command gp strs)
  (gp-flush-command gp))

(define (gp-store-command gp . strs)
  (assert-live gp)
  (set! (gp-cmd gp)
        (conc (gp-cmd gp) " " (string-join strs " "))))

(define (gp-flush-command gp)
  (assert-live gp)
  (display (gp-cmd gp) (gp-out gp))
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

(define (gp-char-ready? gp)
  (assert-live gp)
  (char-ready? (gp-in gp)))

(define (gp-read-all gp)
  (dbg-call "GP-READ-ALL!!!!!")
  (with-output-to-string
      (lambda ()
        (while (gp-char-ready? gp)
          (dbg-call "  GP-READ-CHAR!!")
          (display (read-char (gp-in gp)))))))

(define (gp-kill gp)
  (assert-live gp)
  (gp-send! gp "quit")
  (set! (gp-live? gp) #f)
  (process-signal (gp-bg-pid gp))
  (display (conc "gp(" (gp-pid gp) ") is dead.\n")))

;; (define (gp-repl gp)
;;   (let loop ()
;;     (display "gnuplot> ")
;;     (flush-output)
;;     (let ([line (read-line)])
;;       (cond [(irregex-match '(: "quit" (or (* space)
;;                                            (: (+ space) (* any))))
;;                             (string-trim line))
;;              'done]
;;             [else (gp-send! gp line)
;;                   (flush-output)
;;                   (loop)]))))


