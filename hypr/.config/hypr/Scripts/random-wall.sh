#!/usr/bin/env bash
# Случайные обои через hyprpaper IPC + запись в source-конфиг для персистентности
set -euo pipefail

WALL_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/walls")
MONITOR="${1:-*}"
STATE_CONF="$HOME/.cache/hypr/current-wall.conf"

# случайный файл нужных форматов, .git исключён
wall=$(find "${WALL_DIRS[@]}" -type d -name .git -prune -o \
    -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print \
    | shuf -n 1)

[ -z "$wall" ] && { notify-send "random-wall" "Нет картинок"; exit 1; }

# hyprpaper 0.8.x: preload/unload не реализованы (только "wallpaper" в IPC),
# поэтому смена всегда синхронный decode внутри демона — виден кадр со старыми
# обоями, пока грузится новая картинка. Маскируем чёрной заглушкой на подмену.
BLACK="$(dirname "$0")/black.png"
hyprctl hyprpaper wallpaper "$MONITOR, $BLACK, cover"
sleep 0.2

# сменить сейчас (текущая сессия)
hyprctl hyprpaper wallpaper "$MONITOR, $wall, cover"

# записать для следующего старта (hyprpaper прочитает через source)
mkdir -p "$(dirname "$STATE_CONF")"
cat > "$STATE_CONF" << CONF
wallpaper {
    monitor = $MONITOR
    path = $wall
    fit_mode = cover
}
CONF
