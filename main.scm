(use posix)
(define *gnu* #f)
(define *tmpfile* (create-temporary-file))
(define (start-gnuplot)
  (let-values ([(in out pid) (process "gnuplot 2>&1")]
               [(command) ""])
    (define (read-gnuplot)
      (let ((term (read in)))
        term))
    (define (write-gnuplot strs)
      (for-each (lambda (str) (set! command (string-append command
                                                       (sprintf "~A " str))))
                strs))
    (define (enter)
      (fprintf out command)
      (newline out)
      (display command) (newline)
      (set! command ""))
    (define (quit)
      (fprintf out "quit~%")
      (close-input-port in)
      (close-output-port out)
      (set! in #f)
      (set! out #f)
      (set! *gnu* #f)
      (display "gnuplot killed") (newline))
    (define (dispatch m)
      (if in (cond ((eq? m 'read) (read-gnuplot))
                   ((eq? m 'write) write-gnuplot)
                   ((eq? m 'enter) (enter))
                   ((eq? m 'quit) (quit))
                   ((eq? m 'command) command)
                   ((eq? m 'erase) (set! command ""))
                   (else (error "Undefined Message: " m)))
          (error "gnuplot process has already been killed")))

    (when *gnu* (*gnu* 'quit))
    (set! *gnu* dispatch)
    (display "gnuplot start") (newline)))

(define (g-enter)
  (*gnu* 'enter))
(define (g-write . messages)
  ((*gnu* 'write) messages))
(define (g-command)
  (*gnu* 'command))
(define (g-erase)
  (*gnu* 'erase))
(define (g-quit)
  (if *gnu* (*gnu* 'quit)
      (print "gnuplot process has already been killed"))
  (delete-file* *tmpfile*))
(define (g-read)
  (*gnu* 'read))


;;; plot utility
(define (write-lsts-tmp tmpfile . lsts)
  (with-output-to-file tmpfile
    (lambda ()
      (apply for-each (lambda line
                        (for-each (lambda (x) (printf "~A " x)) line)
                        (newline))
             lsts))))

(define (plot-list #!key (x #f) (y #f) (message #f))
  (cond [(list? x) (cond [(and y (= (length x) (length y)))
                          (write-lsts-tmp *tmpfile* x y)]
                         [else (g-erase) (error "Malformal 'y' data" y)])]
        
        [(list? y) (write-lsts-tmp *tmpfile* (iota (length y)) y)]
        
        [else (error "Please use 'x:' and 'y:' keywords")])    
  (g-write "plot" (sprintf "'~A'" *tmpfile*))
  (when message
    (g-write message))
  (g-enter))

