#!/bin/bash
bar="▁▂▃▄▅▆▇█"
dict="s/;//g"
i=0
while [ $i -lt 8 ]; do
    dict="${dict};s/$i/${bar:$i:1}/g"
    i=$((i+1))
done
# retry-цикл: при автостарте waybar может опередить PipeWire (устройства ещё
# не готовы) — cava падает на первой попытке, а waybar сам его не
# перезапускает (custom-модуль continuous exec не рестартует по себе)
while true; do
    cava -p ~/.config/cava/waybar_config | while read -r line; do
        echo "${line//;/}" | sed "$dict"
    done
    sleep 1
done
