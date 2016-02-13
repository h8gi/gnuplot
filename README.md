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

### gp-plot
`(gp-plot gp x-lst y-lst #!key title (with "linespoints"))`


## example

~~~~~{.scheme}
(use gp)
(define gp (new-gp))
(gp-send-line gp "plot sin(x)")
(gp-kill gp)
~~~~~


`test/`以下を見てください。
