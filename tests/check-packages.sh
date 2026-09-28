#!/usr/bin/env bash
# Comprueba (sin instalar nada) que todos los paquetes que pide install.sh
# existen en los repos de la distro actual. Pensado para ejecutarse como root
# dentro de un contenedor limpio:
#   podman run --rm -v "$PWD:/src:ro,z" fedora:43 bash /src/tests/check-packages.sh
set -u
. /etc/os-release
eval "$(bash "$(dirname "$0")/../install.sh" --print-packages | sed -n 's/^\(RUNTIME\|BUILD\): \(.*\)/\1="\2"/p')"
case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*)   pacman -Sy >/dev/null;       has() { pacman -Si "$1" >/dev/null 2>&1 || pacman -Sg "$1" >/dev/null 2>&1; } ;;
    *" fedora "*) dnf -q makecache >/dev/null; has() { dnf -q repoquery --whatprovides "$1" 2>/dev/null | grep -q .; } ;;
    *" debian "*|*" ubuntu "*) apt-get update >/dev/null; has() { apt-cache show "$1" 2>/dev/null | grep -q '^Package'; } ;;
    *) echo "Distro no soportada por este test"; exit 1 ;;
esac
missing=0
for p in $RUNTIME $BUILD; do has "$p" || { echo "FALTA: $p"; missing=$((missing+1)); }; done
echo "$PRETTY_NAME: $missing paquetes no encontrados"
exit $((missing > 0))
