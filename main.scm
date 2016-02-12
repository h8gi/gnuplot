(use posix miscmacros)
(define-record gp in out pid (setter cmd) (setter live?))
(define-record-printer (gp x out)
  (fprintf out "#<gp: ~S ~A>" (gp-cmd gp) (if (gp-live? gp) "live" "dead")))

(define (assert-live gp)
  (unless (gp-live? gp)
    (error "gp is already dead.")))

(define (new-gp)
  (receive (in out pid) (process "gnuplot 2>&1")
    (make-gp in out pid "" #t)))

(define (gp-read gp)
  (assert-live gp)
  (read-line (gp-in gp)))

(define (gp-store-command gp . strs)
  (assert-live gp)
  (set! (gp-cmd gp)
        (conc (gp-cmd gp) " " (string-join strs " "))))

(define (gp-send-command gp)
  (assert-live gp)
  (display (gp-cmd gp) (gp-out gp))
  (newline (gp-out gp))
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
  (with-output-to-string
      (lambda ()
        (while (gp-char-ready? gp)
          (display (read-char (gp-in gp)))))))



(define (gp-end gp)
  (assert-live gp)
  (gp-store-command gp "quit")
  (gp-send-command gp)
  (set! (gp-live? gp) #f))

(define (gp-repl gp)
  (let loop ()
    (display "gnuplot> ")
    (flush-output)
    (let ([line (read-line)])
      (cond [(irregex-match '(: "quit" (or (* space)
                                           (: (+ space) (* any))))
                            (string-trim line))
             'done]
            [else (gp-store-command gp (read-line))
                  (gp-send-command gp)
                  (when (gp-char-ready? gp)
                    (display (gp-read-all gp)))
                  (flush-output)
                  (loop)]))))

