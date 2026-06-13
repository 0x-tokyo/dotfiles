#!/usr/bin/env bash
# Восстановить последние обои при старте, иначе дефолт
set -euo pipefail

MONITOR="${1:-eDP-2}"
STATE_FILE="$HOME/.cache/hypr/last-wallpaper"
DEFAULT="$HOME/Pictures/Wallpapers/wall.png"

# ждём демон hyprpaper (до 5 сек)
for _ in {1..10}; do
    hyprctl hyprpaper reload "$MONITOR, $DEFAULT, cover" 2>/dev/null && break
    sleep 0.5
done

# если есть сохранённый и файл существует — ставим его
if [[ -f "$STATE_FILE" ]]; then
    wall=$(cat "$STATE_FILE")
    [[ -f "$wall" ]] && hyprctl hyprpaper reload "$MONITOR, $wall, cover"
fi
