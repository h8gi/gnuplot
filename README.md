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

### (plot-data data writer messages)

`(writer data)`が実行される。
その後plotされて、文字列**messages**がgnuplotに送られる。


## example

`test/`以下を見てください。
