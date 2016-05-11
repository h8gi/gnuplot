# GNUPLOT
chicken-schemeからgnuplotを使う。  
`(use gnuplot)`

### gp-start

`(gp-start)`

### gp-flush-command
 `gp-store-command`によって書き込まれていたコマンドをgnuplotに送り実行する。コマンドは消される。

### gp-store-command
`(gp-store-command . str)`で受けとった文字列を蓄える。

### gp-reset-command
`gp-store-command`で書き込まれていたコマンドを消す。

### gp-send-line

コマンドを受けとって送信してメッセージを表示。

~~~~~{.scheme}
(define (gp-send-line . strs)
  (apply gp-store-command strs)
  (gp-flush-command)
  (thread-sleep! 0.01)                  ; wait gnuplot's error message (horrible)
  (display (gp-read-all)))
~~~~~

### gp-show-command
書き込まれているコマンドを確認する。

### gp-read-all
gnuplotからの返事を読む。

### gp-kill
gnuplotプロセスを終了する。

### gp-plot-list
`(gp-plot-list x-lst y-lst #!key title (with "linespoints") (replot #f))`

### gp-plot-file
`(gp-plot-file datafile #!key (using (quote (1 2))) title (with "linespoints") (replot #f))`

### gp-save-plot
`(gp-save-plot filename)`  
直前のplotを保存します。

## example

~~~~~{.scheme}
(gp-start)
(gp-plot-file "test.csv"
              #:using '(1 2)
              #:title "N"
              #:with "lines")
(gp-plot-file "test.csv"
              #:using '(1 3)
              #:title "P"
              #:with "lines"
              #:replot #t)
(gp-kill)
~~~~~

`test/`以下を見てください。
