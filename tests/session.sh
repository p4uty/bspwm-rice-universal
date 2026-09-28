#!/usr/bin/env bash
# Arranca bspwm dentro de Xvfb (lo lanza smoke.sh con DISPLAY y dbus ya preparados)
# y comprueba los procesos de la sesión y cada tema. Escribe en $OUT/session.txt.
set -u
OUT="$1"
bspwm >"$OUT/bspwm.log" 2>&1 &
sleep 15
for p in bspwm sxhkd polybar picom dunst xsettingsd; do
    pgrep -x "$p" >/dev/null && echo "PROC_OK $p" || echo "PROC_MISSING $p"
done
for dir in ~/.config/bspwm/rices/*/; do
    rice=$(basename "$dir")
    echo "$rice" > ~/.config/bspwm/.rice
    timeout 60 Theme.sh >"$OUT/theme-$rice.log" 2>&1 || echo "RICE_TIMEOUT $rice"
    sleep 6
    pgrep -x polybar >/dev/null && echo "RICE_OK $rice" || echo "RICE_NOBAR $rice"
    maim "$OUT/screenshot-$rice.png" 2>/dev/null || import -window root "$OUT/screenshot-$rice.png"
done
# Salida de polybar/picom con mensajes (Bar.bash los lanza en modo silencioso)
pkill -x polybar; sleep 1
for dir in ~/.config/bspwm/rices/*/; do
    rice=$(basename "$dir")
    bar=$(grep -oE "polybar -q [^ ]+" ~/.config/bspwm/rices/"$rice"/Bar.bash | head -1 | cut -d" " -f3)
    timeout 4 polybar "$bar" -c ~/.config/bspwm/rices/"$rice"/config.ini >"$OUT/polybar-$rice.log" 2>&1
done
pkill -x picom; sleep 1
timeout 4 picom --config ~/.config/bspwm/config/picom/picom.conf >"$OUT/picom.log" 2>&1
bspc quit
