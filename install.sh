#!/usr/bin/env bash
# =============================================================
#  bspwm Rice - Instalador universal (Arch / Fedora / Debian / Ubuntu)
#  Basado en gh0stzk/dotfiles. Detecta tu distro automáticamente.
#  Revisa el script antes de ejecutarlo. No lo corras como root.
# =============================================================
set -u
[ "$(id -u)" -eq 0 ] && { echo "No ejecutes esto como root."; exit 1; }

CGR='\033[0;32m'; CYE='\033[0;33m'; CRE='\033[0;31m'; CNC='\033[0m'
DIR="$(cd "$(dirname "$0")" && pwd)"
log()  { printf "${CGR}==>${CNC} %s\n" "$1"; }
warn() { printf "${CYE}[!]${CNC} %s\n" "$1"; }
err()  { printf "${CRE}[x]${CNC} %s\n" "$1"; }

# ── 0) Detección de distro ────────────────────────────────
. /etc/os-release 2>/dev/null || { err "No se pudo leer /etc/os-release"; exit 1; }
FAMILY=""
case " ${ID:-} ${ID_LIKE:-} " in
    *" arch "*|*" archlinux "*)  FAMILY="arch" ;;
    *" fedora "*|*" rhel "*)     FAMILY="fedora" ;;
    *" debian "*|*" ubuntu "*)   FAMILY="debian" ;;
    *" suse "*|*" opensuse "*)   FAMILY="suse" ;;
esac
[ -z "$FAMILY" ] && { err "Distro no soportada (ID=$ID). Soportadas: Arch, Fedora, Debian, Ubuntu."; exit 1; }
log "Distro detectada: ${PRETTY_NAME:-$ID}  (familia: $FAMILY)"

# ── 1) Mapa de paquetes por familia ───────────────────────
case "$FAMILY" in
arch)
  PM_UP="sudo pacman -Sy";  PM_IN="sudo pacman -S --needed --noconfirm"
  RUNTIME="git curl unzip zstd tar bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl xorg-xsetroot xorg-xrandr xorg-xprop \
xorg-xwininfo xorg-xdpyinfo xorg-xkill xorg-xrdb xsettingsd pamixer playerctl redshift \
thunar tumbler gvfs-mtp geany jgmenu imagemagick jq libwebp mpv pavucontrol \
keepassxc lxsession polkit-gnome bat bc eza fzf ripgrep bottom inotify-tools \
papirus-icon-theme python-gobject xdg-user-dirs webp-pixbuf-loader \
ttf-jetbrains-mono ttf-inconsolata"
  BUILD="rust cargo base-devel gtk3 gtk-layer-shell libdbusmenu-glib libdbusmenu-gtk3 \
pkgconf autoconf automake libxcb xcb-util xcb-util-image xcb-util-xrm xcb-util-keysyms \
xcb-util-cursor libxkbcommon libxkbcommon-x11 pam libx11 libev libjpeg-turbo giflib libpng cairo pango" ;;
fedora)
  PM_UP="sudo dnf makecache"; PM_IN="sudo dnf install -y --skip-unavailable"
  RUNTIME="git curl unzip zstd tar bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl xsetroot xrandr xprop xwininfo xdpyinfo xkill xrdb \
xsettingsd pamixer playerctl redshift Thunar tumbler gvfs-mtp geany jgmenu ImageMagick \
jq libwebp mpv pavucontrol keepassxc lxsession polkit-gnome \
bat bc eza fzf ripgrep bottom inotify-tools papirus-icon-theme python3-gobject \
xdg-user-dirs webp-pixbuf-loader jetbrains-mono-fonts-all levien-inconsolata-fonts"
  BUILD="cargo rust gtk3-devel glib2-devel cairo-devel cairo-gobject-devel pango-devel \
gdk-pixbuf2-devel gtk-layer-shell-devel libdbusmenu-devel libdbusmenu-gtk3-devel \
autoconf automake pkgconf-pkg-config make gcc libxcb-devel xcb-util-devel xcb-util-image-devel \
xcb-util-xrm-devel xcb-util-keysyms-devel xcb-util-cursor-devel libxkbcommon-devel \
libxkbcommon-x11-devel pam-devel libX11-devel libev-devel libjpeg-turbo-devel giflib-devel libpng-devel" ;;
debian)
  PM_UP="sudo apt-get update"; PM_IN="sudo apt-get install -y"
  RUNTIME="git curl unzip zstd tar bspwm sxhkd polybar picom rofi dunst feh \
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting \
maim xclip xdotool brightnessctl x11-xserver-utils x11-utils \
xsettingsd pamixer playerctl redshift thunar tumbler gvfs-backends geany jgmenu imagemagick \
jq webp mpv pavucontrol keepassxc lxsession policykit-1-gnome \
bat fzf ripgrep bc inotify-tools papirus-icon-theme python3-gi \
xdg-user-dirs webp-pixbuf-loader fonts-jetbrains-mono fonts-inconsolata"
  BUILD="cargo rustc build-essential pkg-config autoconf automake \
libgtk-3-dev libgtk-layer-shell-dev libdbusmenu-glib-dev libdbusmenu-gtk3-dev \
libxcb1-dev libxcb-util-dev libxcb-image0-dev libxcb-xrm-dev libxcb-keysyms1-dev \
libxcb-cursor-dev libxkbcommon-dev libxkbcommon-x11-dev libpam0g-dev libx11-dev \
libev-dev libjpeg-dev libgif-dev libpng-dev libcairo2-dev libpango1.0-dev libgdk-pixbuf-2.0-dev" ;;
suse)
  PM_UP="sudo zypper refresh"; PM_IN="sudo zypper install -y"
  RUNTIME="git curl unzip zstd tar bspwm sxhkd polybar picom rofi dunst feh kitty alacritty \
zsh maim xclip xdotool brightnessctl xsetroot xrandr xprop xwininfo xdpyinfo xkill xrdb \
xsettingsd pamixer playerctl redshift thunar tumbler gvfs geany jgmenu ImageMagick jq \
mpv pavucontrol keepassxc lxsession bat bc fzf ripgrep inotify-tools \
papirus-icon-theme python3-gobject xdg-user-dirs"
  BUILD="cargo rust gtk3-devel autoconf automake gcc make pkgconf-pkg-config" ;;
esac

# Instala una lista tolerando paquetes ausentes (uno a uno donde haga falta)
pm_install_list() {
    if [ "$FAMILY" = "fedora" ]; then
        $PM_IN $1
    else
        for p in $1; do $PM_IN "$p" >/dev/null 2>&1 || warn "no disponible: $p"; done
    fi
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
if [ "$FAMILY" = "fedora" ] && ! dnf repolist 2>/dev/null | grep -qi rpmfusion; then
    log "Habilitando RPM Fusion ..."
    V=$(rpm -E %fedora)
    sudo dnf install -y \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${V}.noarch.rpm" \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${V}.noarch.rpm" || true
fi
[ "$FAMILY" = "debian" ] && sudo add-apt-repository -y universe 2>/dev/null

# ── 4) Paquetes ───────────────────────────────────────────
log "Actualizando índices ..."; $PM_UP || true
log "Instalando paquetes del sistema ..."; pm_install_list "$RUNTIME"

read -rp "$(printf "${CYE}¿Compilar eww e i3lock-color? (necesarios para el tema z0mbi3 y el bloqueo de pantalla) [y/N]: ${CNC}")" DOBUILD

# ── 5) Fuentes ────────────────────────────────────────────
log "Instalando fuentes de iconos (incluidas) ..."
cp -R "$DIR/assets/fonts/"* "$HOME/.local/share/fonts/" 2>/dev/null
log "Descargando JetBrainsMono Nerd Font ..."
TMP="$(mktemp -d)"
if curl -fL -o "$TMP/JBM.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"; then
    mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNF"
    unzip -oq "$TMP/JBM.zip" "*.ttf" -d "$HOME/.local/share/fonts/JetBrainsMonoNF"
fi
fc-cache -f >/dev/null 2>&1

# ── 6) Temas GTK / iconos / cursor (universales, de gh0stzk) ─
log "Descargando temas GTK / iconos / cursor ..."
BASE="http://gh0stzk.github.io/pkgs/x86_64"
dl_extract() { f="$1-any.pkg.tar.zst"
    curl -fsSL -o "$TMP/$f" "$BASE/$f" || { warn "falló $1"; return; }
    tar --use-compress-program=unzstd -xf "$TMP/$f" -C "$HOME/.local/share/$2" \
        --strip-components=3 "usr/share/$2" 2>/dev/null; }
dl_extract "gh0stzk-gtk-themes-1.0-1" themes
for p in gh0stzk-cursor-qogirr-1.0-1 gh0stzk-icons-tokyo-night-1.0-0 \
         gh0stzk-icons-catppuccin-mocha-1.0-0 gh0stzk-icons-hack-1.0-0; do
    dl_extract "$p" icons
done

# ── 7) Binarios universales (funcionan en cualquier distro) ─
gh_bin_tar() { # $1 repo  $2 patrón-asset  $3 nombre-binario dentro del tar
    u=$(curl -fsSL "https://api.github.com/repos/$1/releases/latest" \
        | grep -oE "\"browser_download_url\": \"[^\"]*$2\"" | head -1 | cut -d'"' -f4)
    [ -z "$u" ] && { warn "no se encontró release de $1"; return; }
    curl -fL -o "$TMP/a.tgz" "$u" || return
    mkdir -p "$TMP/x"; tar xf "$TMP/a.tgz" -C "$TMP/x" 2>/dev/null || unzip -oq "$TMP/a.tgz" -d "$TMP/x"
    find "$TMP/x" -type f -name "$3" -exec cp {} "$HOME/.local/bin/$3" \; ; }

log "Instalando yazi, lazydocker, eza, bottom (binarios) ..."
u=$(curl -fsSL "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -oE '"[^"]*x86_64-unknown-linux-gnu\.zip"' | head -1 | tr -d '"')
[ -n "$u" ] && curl -fL -o "$TMP/yazi.zip" "$u" && unzip -oq "$TMP/yazi.zip" -d "$TMP/yz" \
  && find "$TMP/yz" -type f -name yazi -exec cp {} "$HOME/.local/bin/" \; \
  && find "$TMP/yz" -type f -name ya -exec cp {} "$HOME/.local/bin/" \;
gh_bin_tar "jesseduffield/lazydocker" "Linux_x86_64.tar.gz" "lazydocker"
command -v eza >/dev/null 2>&1 || gh_bin_tar "eza-community/eza" "x86_64-unknown-linux-gnu.tar.gz" "eza"
command -v btm  >/dev/null 2>&1 || gh_bin_tar "ClementTsang/bottom" "x86_64-unknown-linux-gnu.tar.gz" "btm"

log "Instalando Neovim 0.12 (la config usa vim.pack, requiere >= 0.12) ..."
if curl -fL -o "$TMP/nvim.tar.gz" "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"; then
    sudo rm -rf /opt/nvim-0.12 && sudo mkdir -p /opt/nvim-0.12
    sudo tar xzf "$TMP/nvim.tar.gz" -C /opt/nvim-0.12 --strip-components=1
    sudo ln -sf /opt/nvim-0.12/bin/nvim /usr/local/bin/nvim
fi
chmod +x "$HOME/.local/bin/"* 2>/dev/null

# ── 8) Compilar eww e i3lock-color (opcional) ─────────────
if [[ "${DOBUILD:-n}" =~ ^[Yy]$ ]]; then
    log "Instalando dependencias de compilación ..."; pm_install_list "$BUILD"
    log "Compilando eww (X11) ..."
    git clone --depth 1 https://github.com/elkowar/eww.git "$TMP/eww" \
      && ( cd "$TMP/eww" && cargo build --release --no-default-features --features x11 \
           && cp target/release/eww "$HOME/.local/bin/eww" ) || warn "falló eww"
    log "Compilando i3lock-color ..."
    git clone --depth 1 https://github.com/Raymo111/i3lock-color.git "$TMP/i3lc" \
      && ( cd "$TMP/i3lc" && autoreconf -fi >/dev/null 2>&1 && mkdir -p build && cd build \
           && ../configure --prefix=/usr/local --sysconfdir=/etc >/dev/null 2>&1 \
           && make -j"$(nproc)" >/dev/null 2>&1 && sudo make install >/dev/null 2>&1 ) || warn "falló i3lock-color"
else
    warn "Saltado eww/i3lock-color. El tema z0mbi3 (eww) y el bloqueo de pantalla no funcionarán sin ellos."
fi

# ── 9) Copiar dotfiles ────────────────────────────────────
log "Copiando configuraciones ..."
cp -R "$DIR/.config/"* "$HOME/.config/"
cp "$DIR/home/.zshrc" "$HOME/.zshrc"
cp "$DIR/home/.gtkrc-2.0" "$HOME/.gtkrc-2.0" 2>/dev/null
cp -R "$DIR/home/.icons" "$HOME/" 2>/dev/null
chmod +x "$HOME"/.config/bspwm/bin/* "$HOME"/.config/bspwm/bspwmrc 2>/dev/null

# ── 10) Plugins zsh + shell de login ──────────────────────
log "Clonando plugins de zsh ..."
[ -d "$HOME/.config/zsh/plugins/fzf-tab" ] || \
  git clone --depth 1 https://github.com/Aloxaf/fzf-tab.git "$HOME/.config/zsh/plugins/fzf-tab"
[ -d "$HOME/.config/zsh/plugins/zsh-history-substring-search" ] || \
  git clone --depth 1 https://github.com/zsh-users/zsh-history-substring-search.git \
    "$HOME/.config/zsh/plugins/zsh-history-substring-search"
log "Poniendo zsh como shell de login ..."
sudo chsh -s "$(command -v zsh)" "$USER" || warn "Cambia el shell manualmente: chsh -s \$(command -v zsh)"

rm -rf "$TMP"
printf "\n${CGR}=========================================================${CNC}\n"
log "Instalación terminada en $FAMILY."
echo "  1) Cierra sesión."
echo "  2) En el login elige la sesión 'bspwm'."
echo "  3) Dentro: super+c = atajos, super+Return = terminal, Alt+Space = temas."
warn "Si algún paquete no se instaló (aviso [!] arriba), revisa COMPONENTS.md para el nombre en tu distro."
printf "${CGR}=========================================================${CNC}\n"
