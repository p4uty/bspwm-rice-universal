#!/usr/bin/env bash
# =============================================================
#  bspwm Rice - Instalador universal (Arch / Fedora / Debian / Ubuntu)
#  Basado en gh0stzk/dotfiles. Detecta tu distro automáticamente.
#  Revisa el script antes de ejecutarlo. No lo corras como root.
#
#  Uso: ./install.sh [opciones]      (./install.sh --help para ver todas)
# =============================================================
set -u

CGR='\033[0;32m'; CYE='\033[0;33m'; CRE='\033[0;31m'; CNC='\033[0m'
DIR="$(cd "$(dirname "$0")" && pwd)"
log()  { printf "${CGR}==>${CNC} %s\n" "$1"; }
warn() { printf "${CYE}[!]${CNC} %s\n" "$1"; WARNINGS+=("$1"); }
err()  { printf "${CRE}[x]${CNC} %s\n" "$1"; }
WARNINGS=()

usage() {
    cat <<EOF
Uso: ./install.sh [opciones]

  -y, --yes          No hace preguntas (usa las respuestas por defecto).
      --build        Compila eww e i3lock-color sin preguntar.
      --no-build     No compila eww ni i3lock-color.
      --no-chsh      No cambia el shell de login a zsh.
      --print-packages  Muestra los paquetes que se instalarían en esta distro y sale.
  -h, --help         Muestra esta ayuda.

Variables de entorno equivalentes: RICE_YES=1, RICE_BUILD=y|n, RICE_CHSH=0
EOF
}

# ── Opciones ──────────────────────────────────────────────
ASSUME_YES="${RICE_YES:-0}"; DOBUILD="${RICE_BUILD:-}"; DO_CHSH="${RICE_CHSH:-1}"; PRINT_PKGS=0
for a in "$@"; do
    case "$a" in
        -y|--yes)         ASSUME_YES=1 ;;
        --build)          DOBUILD=y ;;
        --no-build)       DOBUILD=n ;;
        --no-chsh)        DO_CHSH=0 ;;
        --print-packages) PRINT_PKGS=1 ;;
        -h|--help)        usage; exit 0 ;;
        *) err "Opción desconocida: $a"; usage; exit 1 ;;
    esac
done

# ── 0) Comprobaciones y detección de distro ───────────────
. /etc/os-release 2>/dev/null || { err "No se pudo leer /etc/os-release"; exit 1; }
FAMILY=""
case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*|*" archlinux "*)  FAMILY="arch" ;;
    *" fedora "*|*" rhel "*)     FAMILY="fedora" ;;
    *" debian "*|*" ubuntu "*)   FAMILY="debian" ;;
    *" suse "*|*" opensuse "*)   FAMILY="suse" ;;
esac
[ -z "$FAMILY" ] && { err "Distro no soportada (ID=${ID:-?}). Soportadas: Arch, Fedora, Debian, Ubuntu."; exit 1; }

# ── 1) Mapa de paquetes por familia ───────────────────────
#  RUNTIME = lo necesario para usar el rice.  BUILD = solo para compilar eww/i3lock-color.
#  Tabla completa y explicada en COMPONENTS.md.
case "$FAMILY" in
arch)
  PM_UP="true"   # en Arch se sincroniza y actualiza junto con la instalación (-Syu), nunca -Sy suelto
  PM_IN="sudo pacman -Syu --needed --noconfirm"
  RUNTIME="git curl unzip zstd tar fontconfig iproute2 xorg-server xorg-xinit bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl xorg-xsetroot xorg-xrandr xorg-xprop xorg-setxkbmap \
xorg-xwininfo xorg-xdpyinfo xorg-xkill xorg-xrdb xsettingsd pamixer libpulse playerctl redshift \
networkmanager bluez-utils pacman-contrib \
thunar tumbler gvfs-mtp geany jgmenu imagemagick jq libwebp mpv pavucontrol \
keepassxc polkit-gnome bat bc eza fzf ripgrep bottom inotify-tools \
papirus-icon-theme python-gobject xdg-user-dirs webp-pixbuf-loader \
ttf-jetbrains-mono ttf-inconsolata"
  BUILD="rust base-devel gtk3 gtk-layer-shell libdbusmenu-glib libdbusmenu-gtk3 \
pkgconf autoconf automake libxcb xcb-util xcb-util-image xcb-util-xrm xcb-util-keysyms \
xcb-util-cursor libxkbcommon libxkbcommon-x11 pam libx11 libev libjpeg-turbo giflib libpng cairo pango" ;;
fedora)
  PM_UP="sudo dnf makecache"
  PM_IN="sudo dnf install -y --skip-unavailable"
  RUNTIME="git curl unzip zstd tar fontconfig iproute xorg-x11-server-Xorg xorg-x11-xinit bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl xsetroot xrandr xprop xwininfo xdpyinfo xkill xrdb setxkbmap \
xsettingsd pamixer pulseaudio-utils playerctl redshift NetworkManager bluez \
Thunar tumbler gvfs-mtp geany jgmenu ImageMagick \
jq libwebp mpv pavucontrol keepassxc mate-polkit \
bat bc eza fzf ripgrep inotify-tools papirus-icon-theme python3-gobject \
xdg-user-dirs webp-pixbuf-loader jetbrains-mono-fonts-all levien-inconsolata-fonts"
  BUILD="cargo rust gtk3-devel glib2-devel cairo-devel cairo-gobject-devel pango-devel \
gdk-pixbuf2-devel gtk-layer-shell-devel libdbusmenu-devel libdbusmenu-gtk3-devel \
autoconf automake pkgconf-pkg-config make gcc libxcb-devel xcb-util-devel xcb-util-image-devel \
xcb-util-xrm-devel xcb-util-keysyms-devel xcb-util-cursor-devel libxkbcommon-devel \
libxkbcommon-x11-devel pam-devel libX11-devel libev-devel libjpeg-turbo-devel giflib-devel \
libpng-devel fontconfig-devel" ;;
debian)
  PM_UP="sudo apt-get update"
  PM_IN="sudo DEBIAN_FRONTEND=noninteractive apt-get install -y"
  RUNTIME="git curl unzip zstd tar fontconfig iproute2 xserver-xorg xinit bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl x11-xserver-utils x11-utils x11-xkb-utils \
xsettingsd pamixer pulseaudio-utils playerctl redshift network-manager bluez \
thunar tumbler gvfs-backends geany jgmenu imagemagick \
jq webp mpv pavucontrol keepassxc lxpolkit \
bat fzf ripgrep bc inotify-tools papirus-icon-theme python3-gi \
xdg-user-dirs webp-pixbuf-loader fonts-jetbrains-mono fonts-inconsolata"
  BUILD="cargo rustc build-essential pkg-config autoconf automake \
libgtk-3-dev libgtk-layer-shell-dev libdbusmenu-glib-dev libdbusmenu-gtk3-dev \
libxcb1-dev libxcb-util-dev libxcb-image0-dev libxcb-xrm-dev libxcb-keysyms1-dev \
libxcb-cursor-dev libxcb-composite0-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-xkb-dev \
libx11-xcb-dev libxkbcommon-dev libxkbcommon-x11-dev libpam0g-dev libx11-dev libfontconfig1-dev \
libev-dev libjpeg-dev libgif-dev libpng-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev" ;;
suse)
  PM_UP="sudo zypper refresh"
  PM_IN="sudo zypper install -y"
  RUNTIME="git curl unzip zstd tar fontconfig iproute2 xorg-x11-server xinit bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh maim xclip xdotool brightnessctl xsetroot xrandr xprop xwininfo xdpyinfo xkill xrdb \
setxkbmap xsettingsd pamixer pulseaudio-utils playerctl redshift NetworkManager bluez \
thunar tumbler gvfs geany jgmenu ImageMagick jq mpv pavucontrol keepassxc lxsession \
bat bc fzf ripgrep inotify-tools papirus-icon-theme python3-gobject xdg-user-dirs"
  BUILD="cargo rust gtk3-devel autoconf automake gcc make pkgconf-pkg-config" ;;
esac

if [ "$PRINT_PKGS" = 1 ]; then
    echo "# familia: $FAMILY"; echo "RUNTIME: $RUNTIME"; echo "BUILD: $BUILD"; exit 0
fi

[ "$(id -u)" -eq 0 ] && { err "No ejecutes esto como root (se pedirá sudo cuando haga falta)."; exit 1; }
[ "$(uname -m)" = "x86_64" ] || { err "Solo se soporta x86_64 (tu arquitectura: $(uname -m))."; exit 1; }
command -v sudo >/dev/null 2>&1 || { err "Necesitas 'sudo' instalado y configurado para tu usuario."; exit 1; }

# Registro completo de la instalación (útil para reportar problemas)
LOGFILE="$HOME/.cache/bspwm-rice-install-$(date +%Y%m%d-%H%M%S).log"
mkdir -p "$HOME/.cache"
exec > >(tee -a "$LOGFILE") 2>&1

log "Distro detectada: ${PRETTY_NAME:-$ID}  (familia: $FAMILY)"
log "Registro de la instalación: $LOGFILE"

# ── Preguntas (todas al principio, para que el resto sea desatendido) ──
if [ -z "$DOBUILD" ]; then
    if [ "$ASSUME_YES" = 1 ]; then DOBUILD=n
    else
        read -rp "$(printf "${CYE}¿Compilar eww e i3lock-color? Necesarios para la cheatsheet (super+c) y el bloqueo de pantalla. Tarda varios minutos [y/N]: ${CNC}")" DOBUILD
    fi
fi

# Pide la contraseña una vez y mantiene sudo activo durante toda la instalación
sudo -v || { err "No se pudo obtener sudo."; exit 1; }
( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Instala una lista de paquetes. Si la instalación en bloque falla (algún nombre
# no existe en tu versión), reintenta uno a uno y avisa de los que falten.
pm_install_list() {
    # shellcheck disable=SC2086
    $PM_IN $1 && return 0
    warn "La instalación en bloque falló; reintentando paquete a paquete ..."
    for p in $1; do $PM_IN "$p" >/dev/null 2>&1 || warn "paquete no disponible: $p"; done
}

# Compara versiones: ver_ge 0.60.0 0.58 -> verdadero
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

# Última versión publicada de un repo de GitHub (sin usar la API, que tiene límite de peticiones)
gh_latest_tag() {
    curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$1/releases/latest" | sed 's|.*/tag/||'
}

# ── 2) Backup de configs previos ──────────────────────────
BK="$HOME/.RiceBackup/$(date +%Y%m%d-%H%M%S)"; mkdir -p "$BK"
log "Backup de configs previos en $BK"
mkdir -p "$HOME/.local/bin" "$HOME/.local/share/fonts" "$HOME/.local/share/themes" \
         "$HOME/.local/share/icons" "$HOME/.config/zsh/plugins"
for c in bspwm kitty alacritty dunst nvim yazi zathura mpv geany gtk-3.0; do
    [ -e "$HOME/.config/$c" ] && mv "$HOME/.config/$c" "$BK/"
done
for f in .zshrc .gtkrc-2.0; do [ -e "$HOME/$f" ] && cp "$HOME/$f" "$BK/" 2>/dev/null; done

# ── 3) Repos extra ────────────────────────────────────────
if [ "${ID:-}" = "ubuntu" ] && command -v add-apt-repository >/dev/null 2>&1; then
    sudo add-apt-repository -y universe >/dev/null 2>&1
fi

# ── 4) Paquetes ───────────────────────────────────────────
log "Actualizando índices ..."; $PM_UP || true
log "Instalando paquetes del sistema ..."; pm_install_list "$RUNTIME"
# Opcionales: pueden no existir en todas las versiones; si faltan se sustituyen por binarios
[ "$FAMILY" = "debian" ] && $PM_IN eza >/dev/null 2>&1

# ── 5) Fuentes ────────────────────────────────────────────
log "Instalando fuentes de iconos (incluidas en el repo) ..."
cp -R "$DIR/assets/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null
log "Descargando JetBrainsMono Nerd Font ..."
if curl -fsSL -o "$TMP/JBM.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNF"
    unzip -oq "$TMP/JBM.zip" "*.ttf" -d "$HOME/.local/share/fonts/JetBrainsMonoNF"
else
    warn "No se pudo descargar JetBrainsMono Nerd Font (los iconos de la barra pueden verse mal)."
fi
fc-cache -f >/dev/null 2>&1

# ── 6) Temas GTK / iconos / cursor (universales, de gh0stzk) ─
log "Descargando temas GTK / iconos / cursor ..."
BASE="https://gh0stzk.github.io/pkgs/x86_64"
dl_extract() { f="$1-any.pkg.tar.zst"
    curl -fsSL -o "$TMP/$f" "$BASE/$f" || { warn "no se pudo descargar $1"; return; }
    tar --use-compress-program=unzstd -xf "$TMP/$f" -C "$HOME/.local/share/$2" \
        --strip-components=3 "usr/share/$2" 2>/dev/null || warn "no se pudo extraer $1"; }
dl_extract "gh0stzk-gtk-themes-1.0-1" themes
for p in gh0stzk-cursor-qogirr-1.0-1 gh0stzk-icons-tokyo-night-1.0-0 \
         gh0stzk-icons-catppuccin-mocha-1.0-0 gh0stzk-icons-hack-1.0-0; do
    dl_extract "$p" icons
done

# ── 7) Binarios universales (funcionan en cualquier distro) ─
# Descarga un .tar.gz/.zip de una release y copia los binarios indicados a ~/.local/bin
gh_install() { # $1 url  $2.. binarios
    url="$1"; shift
    rm -rf "$TMP/x" "$TMP/a"; mkdir -p "$TMP/x"
    curl -fsSL -o "$TMP/a" "$url" || { warn "no se pudo descargar $url"; return 1; }
    tar xf "$TMP/a" -C "$TMP/x" 2>/dev/null || unzip -oq "$TMP/a" -d "$TMP/x" || { warn "no se pudo extraer $url"; return 1; }
    for b in "$@"; do
        find "$TMP/x" -type f -name "$b" -exec install -m 755 {} "$HOME/.local/bin/$b" \;
    done
}
GH="https://github.com"

log "Instalando yazi y lazydocker (binarios oficiales) ..."
gh_install "$GH/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-musl.zip" yazi ya
V=$(gh_latest_tag jesseduffield/lazydocker)
[ -n "$V" ] && gh_install "$GH/jesseduffield/lazydocker/releases/download/$V/lazydocker_${V#v}_Linux_x86_64.tar.gz" lazydocker

command -v eza >/dev/null 2>&1 || { log "Instalando eza (binario) ...";
    gh_install "$GH/eza-community/eza/releases/latest/download/eza_x86_64-unknown-linux-musl.tar.gz" eza; }
command -v btm >/dev/null 2>&1 || { log "Instalando bottom (binario) ...";
    gh_install "$GH/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" btm; }

# fzf-tab y el .zshrc usan opciones de fzf >= 0.58 (Debian/Ubuntu traen versiones más antiguas)
FZF_V=$(fzf --version 2>/dev/null | cut -d' ' -f1)
if [ -z "$FZF_V" ] || ! ver_ge "$FZF_V" 0.58; then
    log "Instalando fzf reciente (el de tu distro es ${FZF_V:-inexistente}) ..."
    V=$(gh_latest_tag junegunn/fzf)
    [ -n "$V" ] && gh_install "$GH/junegunn/fzf/releases/download/$V/fzf-${V#v}-linux_amd64.tar.gz" fzf
fi

# La config de Neovim usa vim.pack, que requiere Neovim >= 0.12
NVIM_V=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [ -z "$NVIM_V" ] || ! ver_ge "$NVIM_V" 0.12; then
    log "Instalando Neovim estable en /opt/nvim (el de tu distro es ${NVIM_V:-inexistente}) ..."
    if curl -fsSL -o "$TMP/nvim.tar.gz" "$GH/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"; then
        sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim
        sudo tar xzf "$TMP/nvim.tar.gz" -C /opt/nvim --strip-components=1
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    else
        warn "No se pudo descargar Neovim."
    fi
fi

# Compatibilidad de nombres entre distros
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"          # Debian/Ubuntu: bat se llama batcat
fi
if ! command -v magick >/dev/null 2>&1 && command -v convert >/dev/null 2>&1; then
    printf '#!/bin/sh\n# ImageMagick 6 no trae "magick"; los scripts del rice lo usan como convert.\nexec convert "$@"\n' \
        > "$HOME/.local/bin/magick"; chmod +x "$HOME/.local/bin/magick"
fi

# ── 8) Compilar eww e i3lock-color (opcional) ─────────────
if [[ "${DOBUILD:-n}" =~ ^[YySs]$ ]]; then
    log "Instalando dependencias de compilación ..."; pm_install_list "$BUILD"

    # eww necesita un Rust reciente; si el de la distro es viejo se usa rustup (en ~/.cargo, sin tocar el sistema)
    RUST_V=$(rustc --version 2>/dev/null | cut -d' ' -f2)
    if [ -z "$RUST_V" ] || ! ver_ge "$RUST_V" 1.85; then
        log "Rust de la distro demasiado antiguo (${RUST_V:-no instalado}); instalando rustup en ~/.cargo ..."
        curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal --no-modify-path >/dev/null
    fi
    [ -x "$HOME/.cargo/bin/cargo" ] && export PATH="$HOME/.cargo/bin:$PATH"

    log "Compilando eww (backend X11, tarda unos minutos) ..."
    if git clone -q --depth 1 https://github.com/elkowar/eww.git "$TMP/eww" \
       && ( cd "$TMP/eww" && cargo build -q --release --no-default-features --features x11 ) >"$TMP/eww.log" 2>&1; then
        install -m 755 "$TMP/eww/target/release/eww" "$HOME/.local/bin/eww"
    else
        cp "$TMP/eww.log" "$HOME/.cache/bspwm-rice-eww-build.log" 2>/dev/null
        warn "falló la compilación de eww (log: ~/.cache/bspwm-rice-eww-build.log)"
    fi

    log "Compilando i3lock-color ..."
    if git clone -q --depth 1 https://github.com/Raymo111/i3lock-color.git "$TMP/i3lc" \
       && ( cd "$TMP/i3lc" && autoreconf -fi && mkdir -p build && cd build \
            && ../configure --prefix=/usr/local --sysconfdir=/etc && make -j"$(nproc)" ) >"$TMP/i3lc.log" 2>&1 \
       && ( cd "$TMP/i3lc/build" && sudo make install ) >>"$TMP/i3lc.log" 2>&1; then
        :
    else
        cp "$TMP/i3lc.log" "$HOME/.cache/bspwm-rice-i3lock-build.log" 2>/dev/null
        warn "falló la compilación de i3lock-color (log: ~/.cache/bspwm-rice-i3lock-build.log)"
    fi
else
    log "Saltada la compilación de eww/i3lock-color (sin cheatsheet ni bloqueo de pantalla). Puedes volver a ejecutar con --build."
fi

# ── 9) Copiar dotfiles ────────────────────────────────────
log "Copiando configuraciones ..."
cp -R "$DIR/.config/"* "$HOME/.config/"
cp "$DIR/home/.zshrc" "$HOME/.zshrc"
cp "$DIR/home/.gtkrc-2.0" "$HOME/.gtkrc-2.0" 2>/dev/null
cp -R "$DIR/home/.icons" "$HOME/" 2>/dev/null
chmod +x "$HOME"/.config/bspwm/bin/* "$HOME"/.config/bspwm/bspwmrc 2>/dev/null
command -v xdg-user-dirs-update >/dev/null 2>&1 && xdg-user-dirs-update 2>/dev/null

# ── 10) Plugins zsh + shell de login ──────────────────────
log "Clonando plugins de zsh ..."
[ -d "$HOME/.config/zsh/plugins/fzf-tab" ] || \
  git clone -q --depth 1 https://github.com/Aloxaf/fzf-tab.git "$HOME/.config/zsh/plugins/fzf-tab"
[ -d "$HOME/.config/zsh/plugins/zsh-history-substring-search" ] || \
  git clone -q --depth 1 https://github.com/zsh-users/zsh-history-substring-search.git \
    "$HOME/.config/zsh/plugins/zsh-history-substring-search"
if [ "$DO_CHSH" = 1 ] && [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    log "Poniendo zsh como shell de login ..."
    sudo chsh -s "$(command -v zsh)" "$USER" 2>/dev/null \
      || sudo usermod -s "$(command -v zsh)" "$USER" 2>/dev/null \
      || warn "No se pudo cambiar el shell. Hazlo a mano: chsh -s \$(command -v zsh)"
fi

# ── 11) Verificación final ────────────────────────────────
has_polkit_agent() {
    for a in /usr/bin/lxpolkit /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
             /usr/libexec/polkit-gnome-authentication-agent-1 /usr/libexec/polkit-mate-authentication-agent-1 \
             /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1; do
        [ -x "$a" ] && return 0
    done
    return 1
}
log "Verificando comandos necesarios ..."
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
MISSING=""
for c in bspwm sxhkd polybar picom rofi dunst dunstify feh kitty alacritty zsh maim xclip xdotool \
         xsetroot xrandr xprop setxkbmap xsettingsd pamixer pactl playerctl thunar geany jgmenu magick \
         jq mpv keepassxc bat eza fzf rg btm inotifywait bc yazi nvim lazydocker; do
    command -v "$c" >/dev/null 2>&1 || MISSING="$MISSING $c"
done
[ -e /usr/share/xsessions/bspwm.desktop ] || warn "No existe /usr/share/xsessions/bspwm.desktop: tu gestor de login no mostrará la sesión bspwm."
[ -n "$MISSING" ] && warn "Comandos que no se encontraron:$MISSING"
has_polkit_agent || warn "No se encontró un agente polkit: las apps gráficas no podrán pedir la contraseña de administrador."

printf "\n${CGR}=========================================================${CNC}\n"
log "Instalación terminada ($FAMILY)."
echo "  1) Cierra sesión."
echo "  2) En la pantalla de login elige la sesión 'bspwm' (X11)."
echo "  3) Dentro: super+Return = terminal, super+Space = apps, Alt+Space = temas, super+c = atajos."
echo "  Backup de tu config anterior: $BK"
echo "  Registro completo: $LOGFILE"
if [ ${#WARNINGS[@]} -gt 0 ]; then
    printf "\n${CYE}Avisos durante la instalación:${CNC}\n"
    printf '  - %s\n' "${WARNINGS[@]}"
    echo "  Consulta COMPONENTS.md y la sección 'Solución de problemas' del README."
fi
printf "${CGR}=========================================================${CNC}\n"
