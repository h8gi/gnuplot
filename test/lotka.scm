(use gnuplot srfi-1)
;; Lotka-Volterraの捕食 被食モデル
;; 餌の密度: N
;; 捕食者の密度: P
;; Nの増加率: r
;; 捕食効率: a
;; 接触した餌の繁殖への変換効率:b
;; 死亡率: d
(define (make-model #!key N0 P0 r a b d K)
  (let ((N N0) (P P0) (result-lst `((0 ,N0 ,P0))) (counter 0))
    (define (one-step)
      (let ((newN (+ N
                     (- (* N r
                           (- 1 (/ N K))
                           )
                        (* a N P))))
            (newP (+ P
                     (- (* b a N P)
                        (* d P)))))
        (set! N newN)
        (set! P newP)
        (set! counter (+ counter 1))
        (set! result-lst (cons `(,counter ,N ,P) result-lst))))
    (define (step n)
      (cond ((zero? n) 'done)
            (else (one-step) (step (- n 1)))))
    (define (reset)
      (set! N N0) (set! P P0) (set! counter 0) (set! result-lst `((,counter ,N0 ,P0))))
    (define (get-result)
      result-lst)
    (lambda (message)
      (cond ((eq? message 'one-step) (one-step))
            ((eq? message 'step) step)
            ((eq? message 'reset) (reset))
            ((eq? message 'get) (get-result))
            (else (error "Unefined message: " message))))))


(define (write-result result)
  (printf "#T\tN\tP~%")
  (let loop ((lst (reverse result)))
    (cond ((null? lst) 'done)
          (else (printf "~A\t~A\t~A~%" (first (car lst)) (second (car lst)) (third (car lst)))
                (loop (cdr lst))))))

(define model (make-model N0: 0.3
                          P0: 0.3
                          r:  0.1
                          a:  0.35
                          b:  0.47
                          d:  0.035
                          K:  1.1))
((model 'step) 1000)
(with-output-to-file "test.csv" (lambda () (write-result (model 'get))))


(define (test gp)
  (gp-send! gp
            "plot 'test.csv'"
            "using 1:2 title 'N' with lines,"
            "'test.csv'"
            "using 1:3 title 'P' with lines"))

(define gp (new-gp))
(test gp)
(gp-kill gp)
