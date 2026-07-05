# Wireshark pentest profile — что накликать

## preferences
```
gui.column.hidden: 
gui.column.format: 
	"No.", "%m",
	"Time", "%t",
	"Delta", "%Gt",
	"Source", "%s",
	"Destination", "%d",
	"Protocol", "%p",
	"Length", "%L",
	"Info", "%i",
	"Source port", "%uS"
gui.qt.font_name: JetBrainsMono Nerd Font,10,-1,5,500,0,0,0,0,0,0,0,0,0,0,1,,0,0
nameres.transport_name: TRUE
tcp.reassemble_out_of_order: TRUE
```

## GUI-эквивалент
- Columns: No / Time / Delta / Source / Destination / Protocol / Length / Info / Source port (**%uS = unresolved**)
- Font: JetBrainsMono Nerd Font 10
- Name Resolution: transport ON (MAC ON + IP OFF — дефолты, в файл не пишутся)
- Protocols → TCP: reassemble out-of-order ON

## Симлинки (stow, не тут)
colorfilters · dfilter_buttons · decode_as_entries
