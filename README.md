# GNUPLOT
chicken-schemeからgnuplotを使う。  
`(use gnuplot)`

### start-gnuplot 

`(start-gnuplot)`でプロセスを開始する。

### g-enter 
`g-write`で書き込まれていたコマンドをgnuplotに送り、実行する。コマンドは消される。

### g-write 
`(g-write str)`で受けとった文字列を蓄える。

### g-erase
`g-write`で書き込まれていたコマンドを消す。

### g-quit 
gnuplotプロセスを終了する。

### g-read
gnuplotからの返事を読む。

### g-command
現在書き込まれているコマンドを返す。

### (plot-list #!key x y message)

**y** は必須。**x**が無い場合勝手になんとかします。  
**message**はplotに渡されるオプション文字列  

## example

`test/`以下を見てください。
