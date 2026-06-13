#!/usr/bin/env bash
# Случайные обои через hyprpaper IPC + запоминание выбора
set -euo pipefail

WALL_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/walls")
MONITOR="${1:-eDP-2}"
STATE_FILE="$HOME/.cache/hypr/last-wallpaper"

# случайный файл из всех папок, .git исключён
wall=$(find "${WALL_DIRS[@]}" -type d -name .git -prune -o \
    -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print \
    | shuf -n 1)

[ -z "$wall" ] && { notify-send "random-wall" "Нет картинок"; exit 1; }

hyprctl hyprpaper wallpaper "$MONITOR, $wall, cover"

# запомнить выбор
mkdir -p "$(dirname "$STATE_FILE")"
printf '%s\n' "$wall" > "$STATE_FILE"
