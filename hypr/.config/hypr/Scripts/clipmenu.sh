#!/bin/bash
selected=$(cliphist list | rofi -dmenu -p "Clipboard")
[ -z "$selected" ] && exit 0          # Esc/пустой выбор — выходим, буфер не трогаем
echo "$selected" | cliphist decode | wl-copy
