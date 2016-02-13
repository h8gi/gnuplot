# GNUPLOT
chicken-schemeからgnuplotを使う。  
`(use gnuplot)`

### new-gp

`(new-gp) => #<gp>`

### gp-flush-command
 `gp-store-command`によって書き込まれていたコマンドをgnuplotに送り実行する。コマンドは消される。

### gp-store-command
`(gp-store-command gp . str)`で受けとった文字列を蓄える。

### gp-reset-command
`g-write`で書き込まれていたコマンドを消す。

### gp-send-line

コマンドを受けとって送信してメッセージを表示。

~~~~~{.scheme}
(define (gp-send-line gp . strs)
  (apply gp-store-command gp strs)
  (gp-flush-command gp)
  (thread-sleep! 0.01)                  ; wait gnuplot's error message (horrible)
  (display (gp-read-all gp)))
~~~~~

### gp-show-command
書き込まれているコマンドを確認する。

### gp-read-all
gnuplotからの返事を読む。

### gp-kill
gnuplotプロセスを終了する。

### gp-plot-list
`(gp-plot-list gp x-lst y-lst #!key title (with "linespoints"))`

### gp-plot-file
`(gp-plot-file gp datafile #!key (using (quote (1 2))) title (with "linespoints") (replot #f))`

## example

~~~~~{.scheme}
(define gp (new-gp))
(gp-plot-file gp "test.csv"
              #:using '(1 2)
              #:title "N"
              #:with "lines")
(gp-plot-file gp "test.csv"
              #:using '(1 3)
              #:title "P"
              #:with "lines"
              #:replot #t)
(gp-kill gp)
~~~~~

`test/`以下を見てください。
