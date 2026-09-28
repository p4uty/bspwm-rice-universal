#!/usr/bin/env bash
# Prueba de humo (se ejecuta como el usuario que instaló el rice):
#   1. comandos instalados   2. sintaxis de scripts   3. zsh y neovim arrancan
#   4. sesión bspwm real en Xvfb con los 3 temas (procesos + capturas)
set -u
OUT="$HOME/smoke"; mkdir -p "$OUT"
export PATH="$HOME/.config/bspwm/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
FAIL=0; NOTES=()
ok()   { echo "  [ok]   $1"; }
bad()  { echo "  [FALLO] $1"; FAIL=1; NOTES+=("$1"); }
note() { echo "  [aviso] $1"; NOTES+=("$1"); }

echo "== 1. Comandos"
for c in bspwm sxhkd polybar picom rofi dunst dunstify feh kitty alacritty zsh xsettingsd xdotool xprop jq; do
    command -v "$c" >/dev/null && ok "$c" || bad "falta comando esencial: $c"
done
for c in maim xclip xsetroot xrandr setxkbmap pamixer pactl playerctl thunar geany jgmenu magick mpv \
         keepassxc bat eza fzf rg btm inotifywait bc yazi nvim lazydocker nmcli bluetoothctl; do
    command -v "$c" >/dev/null && ok "$c" || note "falta comando secundario: $c"
done
FZF_V=$(fzf --version 2>/dev/null | cut -d' ' -f1)
[ "$(printf '%s\n0.58\n' "$FZF_V" | sort -V | head -1)" = 0.58 ] && ok "fzf $FZF_V >= 0.58" || bad "fzf $FZF_V es < 0.58"
[ -e /usr/share/xsessions/bspwm.desktop ] && ok "sesión bspwm.desktop registrada" || bad "no existe /usr/share/xsessions/bspwm.desktop"

echo "== 2. Sintaxis de scripts"
for f in ~/.config/bspwm/bspwmrc ~/.config/bspwm/bin/* ~/.config/bspwm/config/modules/*.sh ~/.config/bspwm/rices/*/*.bash; do
    head -1 "$f" | grep -q python && continue
    sh_=$(head -1 "$f" | grep -q bash && echo bash || echo sh)
    [ "${f##*.}" = bash ] && sh_=bash
    $sh_ -n "$f" 2>"$OUT/syntax.tmp" || bad "sintaxis: $f ($(head -1 "$OUT/syntax.tmp"))"
done
ok "revisados $(ls ~/.config/bspwm/bin | wc -l) scripts"

echo "== 3. Shell y editor"
zsh -i -c 'exit' >"$OUT/zsh.log" 2>&1 </dev/null
if grep -qiE 'not found|no such file|error|bad option|unknown option' "$OUT/zsh.log"; then bad "zsh -i muestra errores (ver zsh.log)"; else ok "zsh -i arranca limpio"; fi
zsh -i -c 'alias ls cat' >>"$OUT/zsh.log" 2>&1 </dev/null
# La primera vez vim.pack pide confirmación para instalar plugins; aquí solo se
# comprueba que la config carga sin errores de Lua.
timeout 60 nvim --headless '+qa!' </dev/null >"$OUT/nvim.log" 2>&1
grep -qE 'E5113|stack traceback|^E[0-9]+:' "$OUT/nvim.log" && bad "neovim: error en la configuración (ver nvim.log)" || ok "neovim carga la config ($(nvim --version | head -1))"

echo "== 4. Sesión bspwm en Xvfb"
Xvfb :99 -screen 0 1920x1080x24 -nolisten tcp >"$OUT/xvfb.log" 2>&1 &
sleep 2
export DISPLAY=:99
dbus-run-session -- bash "$(dirname "$0")/session.sh" "$OUT" >"$OUT/session.txt" 2>&1
kill %1 2>/dev/null
ls /usr/bin/lxpolkit /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 /usr/libexec/polkit-mate-authentication-agent-1 2>/dev/null | grep -q . \
    && ok "agente polkit instalado" || note "sin agente polkit"
while read -r kind what; do
    case $kind in
        PROC_OK|RICE_OK) ok "$kind $what" ;;
        PROC_MISSING) [ "$what" = picom ] && note "picom no quedó en marcha (normal en Xvfb sin GPU; ver picom.log)" || bad "proceso no arrancó: $what" ;;
        RICE_NOBAR) bad "tema $what: polybar no arrancó (ver polybar-$what.log)" ;;
        RICE_TIMEOUT) bad "tema $what: Theme.sh no terminó en 60 s" ;;
    esac
done <"$OUT/session.txt"
for f in "$OUT"/polybar-*.log; do
    n=$(grep -c '^error' "$f"); [ "$n" -gt 0 ] && note "$(basename "$f"): $n errores de polybar"
done
grep -qiE 'command not found|not found' "$OUT/bspwm.log" "$OUT"/theme-*.log && note "comandos no encontrados en bspwm/Theme.sh (ver logs)"

echo
printf '%s\n' "${NOTES[@]}" >"$OUT/notes.txt"
if [ $FAIL = 0 ]; then echo "RESULTADO: OK (${#NOTES[@]} avisos)" | tee "$OUT/summary.txt"
else echo "RESULTADO: FALLO (${#NOTES[@]} problemas)" | tee "$OUT/summary.txt"; fi
exit $FAIL
