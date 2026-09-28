#!/usr/bin/env bash
# =============================================================
#  Prueba install.sh en contenedores limpios de cada distro y
#  arranca una sesión bspwm real (Xvfb) para comprobar que funciona.
#
#  Uso:   tests/run-tests.sh [distro ...]
#  Ej.:   tests/run-tests.sh                 # todas
#         tests/run-tests.sh fedora debian12
#  Opciones por entorno:
#         RICE_BUILD=y   también compila eww e i3lock-color (lento)
#         ENGINE=docker  usa docker en vez de podman
#
#  Resultados (logs + capturas de cada tema) en tests/results/<distro>/
# =============================================================
set -u
cd "$(dirname "$0")/.." || exit 1

ENGINE="${ENGINE:-$(command -v podman >/dev/null 2>&1 && echo podman || echo docker)}"
declare -A IMAGES=(
    [arch]=docker.io/library/archlinux:latest
    [fedora]=docker.io/library/fedora:43
    [debian12]=docker.io/library/debian:12
    [debian13]=docker.io/library/debian:13
    [ubuntu2404]=docker.io/library/ubuntu:24.04
)
ALL="arch fedora debian12 debian13 ubuntu2404"
TARGETS="${*:-$ALL}"

for t in $TARGETS; do
    [ -n "${IMAGES[$t]:-}" ] || { echo "Distro desconocida: $t (opciones: $ALL)"; exit 1; }
done

run_one() {
    t=$1; out="tests/results/$t"
    rm -rf "$out"; mkdir -p "$out"
    "$ENGINE" run --rm \
        -e RICE_BUILD="${RICE_BUILD:-n}" \
        -v "$PWD:/src:ro,z" -v "$PWD/$out:/out:z" \
        "${IMAGES[$t]}" bash /src/tests/container-test.sh >"$out/full.log" 2>&1
    echo $? >"$out/exit-code"
}

for t in $TARGETS; do run_one "$t" & done
wait

printf "\n%-12s %-8s %s\n" DISTRO RESULT DETALLE
fail=0
for t in $TARGETS; do
    out="tests/results/$t"; code=$(cat "$out/exit-code" 2>/dev/null || echo 99)
    if [ "$code" = 0 ]; then res="OK"; else res="FALLO"; fail=1; fi
    printf "%-12s %-8s %s\n" "$t" "$res" "$(tail -1 "$out/summary.txt" 2>/dev/null || echo 'ver full.log')"
done
exit $fail
