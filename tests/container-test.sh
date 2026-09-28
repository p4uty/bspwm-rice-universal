#!/usr/bin/env bash
# Se ejecuta DENTRO del contenedor (como root): prepara un usuario normal con
# sudo, ejecuta install.sh como ese usuario y luego la prueba de humo.
set -u
. /etc/os-release
echo "### Contenedor: $PRETTY_NAME"

# Herramientas mínimas que en un escritorio real ya existen (sudo, dbus, Xvfb para la prueba)
case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*)
        sed -i 's/^DownloadUser/#DownloadUser/' /etc/pacman.conf   # el sandbox de pacman falla en contenedores
        pacman -Syu --noconfirm --needed sudo xorg-server-xvfb dbus procps-ng which mesa >/dev/null ;;
    *" fedora "*)
        dnf install -y sudo xorg-x11-server-Xvfb dbus-daemon dbus-tools procps-ng which findutils \
            util-linux-user mesa-dri-drivers glibc-langpack-es >/dev/null ;;
    *" debian "*|*" ubuntu "*)
        apt-get update >/dev/null
        DEBIAN_FRONTEND=noninteractive apt-get install -y sudo xvfb dbus dbus-x11 procps ca-certificates \
            libgl1-mesa-dri >/dev/null ;;
esac

useradd -m -s /bin/bash tester
echo 'tester ALL=(ALL) NOPASSWD: ALL' >/etc/sudoers.d/tester
cp -r /src /home/tester/rice && rm -rf /home/tester/rice/tests/results
chown -R tester: /home/tester/rice

echo "### install.sh"
su - tester -c "cd ~/rice && ./install.sh --yes $( [ "${RICE_BUILD:-n}" = y ] && echo --build || echo --no-build )"
echo "install.sh terminó con código $?"

echo "### Prueba de humo"
su - tester -c "bash ~/rice/tests/smoke.sh"; rc=$?

mkdir -p /out
cp -r /home/tester/smoke/. /out/ 2>/dev/null
cp /home/tester/.cache/bspwm-rice-install-*.log /out/install.log 2>/dev/null
exit $rc
