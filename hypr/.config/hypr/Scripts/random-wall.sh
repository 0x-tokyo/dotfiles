#!/usr/bin/env bash
# Случайные обои через hyprpaper IPC + запись в source-конфиг для персистентности
set -euo pipefail

ALL_WALL_DIRS=("$HOME/Pictures/Wallpapers" "$HOME/Pictures/walls")
CONF_MONITOR="${1:-*}"
STATE_CONF="$HOME/.cache/hypr/current-wall.conf"

# монитор(ы) для live IPC-переключения. "" технически проходит валидацию
# hyprpaper (IPC.cpp пропускает проверку при m_monitor.empty()), но эмпирически
# не применяется визуально при live-apply (в отличие от статического конфига,
# где wildcard реально работает) — поэтому резолвим реальные имена и шлём на
# каждый явно.
if [ -n "${1:-}" ]; then
    IPC_MONITORS=("$1")
else
    mapfile -t IPC_MONITORS < <(hyprctl monitors -j | python3 -c 'import json,sys; [print(m["name"]) for m in json.load(sys.stdin)]')
fi

# пропускаем каталоги, которых на этой машине ещё нет (напр. $HOME/Pictures/walls —
# опциональный клон github.com/dharmx/walls, не на всех машинах склонирован)
WALL_DIRS=()
for d in "${ALL_WALL_DIRS[@]}"; do
    [ -d "$d" ] && WALL_DIRS+=("$d")
done
[ "${#WALL_DIRS[@]}" -eq 0 ] && { notify-send "random-wall" "Нет каталогов с обоями"; exit 1; }

# случайный файл нужных форматов, .git исключён
wall=$(find "${WALL_DIRS[@]}" -type d -name .git -prune -o \
    -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' \) -print \
    | shuf -n 1)

[ -z "$wall" ] && { notify-send "random-wall" "Нет картинок"; exit 1; }

# hyprpaper 0.8.x: preload/unload не реализованы (только "wallpaper" в IPC),
# поэтому смена всегда синхронный decode внутри демона — виден кадр со старыми
# обоями, пока грузится новая картинка. Маскируем чёрной заглушкой на подмену.
BLACK="$(dirname "$0")/black.png"
for m in "${IPC_MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$m, $BLACK, cover"
done
sleep 0.2

# сменить сейчас (текущая сессия)
for m in "${IPC_MONITORS[@]}"; do
    hyprctl hyprpaper wallpaper "$m, $wall, cover"
done

# записать для следующего старта (hyprpaper прочитает через source)
mkdir -p "$(dirname "$STATE_CONF")"
cat > "$STATE_CONF" << CONF
wallpaper {
    monitor = $CONF_MONITOR
    path = $wall
    fit_mode = cover
}
CONF
