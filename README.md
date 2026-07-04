# 🐧 bspwm Rice — Dotfiles universales

Entorno de escritorio **bspwm** para **Linux**, basado en los
[dotfiles de gh0stzk](https://github.com/gh0stzk/dotfiles) y **adaptado para ser
multi-distro**. Un solo instalador detecta tu distro e instala todo:

**✅ Arch · Fedora · Debian · Ubuntu** (y base para openSUSE).

Los archivos de configuración son idénticos en todas las distros; lo único que
cambia es la instalación de paquetes (ver **[COMPONENTS.md](COMPONENTS.md)** para
el mapa de paquetes por distro).

Convive con tu escritorio actual (GNOME/KDE): se elige la sesión **bspwm** en el
gestor de inicio de sesión, sin tocar tu entorno principal.

---

## 📑 Índice
- 📄 **[COMPONENTS.md](COMPONENTS.md)** — mapa de paquetes por distro (Arch/Fedora/Debian/openSUSE)
- [Componentes](#-componentes)
- [Temas (rices)](#-temas-rices)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Paquetes instalados](#-paquetes-instalados-dnf)
- [Instalado/compilado a mano](#-instaladocompilado-a-mano)
- [Fuentes](#-fuentes)
- [Temas GTK, iconos y cursor](#-temas-gtk-iconos-y-cursor)
- [Adaptaciones Arch → Fedora](#-adaptaciones-arch--fedora)
- [Personalizaciones propias](#-personalizaciones-propias)
- [Atajos de teclado](#-atajos-de-teclado)
- [Créditos](#-créditos)

---

## 🧩 Componentes

| Rol | Herramienta |
|---|---|
| Window Manager | **bspwm** |
| Atajos de teclado | **sxhkd** |
| Barra | **polybar** (los 3 temas) |
| Compositor | **picom** (v13, con animaciones) |
| Lanzador / menús | **rofi** |
| Notificaciones | **dunst** |
| Terminal | **kitty** (por defecto) · alacritty (alterna) |
| Shell | **zsh** (autosuggestions, syntax-highlighting, fzf-tab, prompt propio) |
| Gestor de archivos | **yazi** (TUI) · **Thunar** (GUI) |
| Editor | **Neovim 0.12** (config con `vim.pack`) · geany |
| Navegador | **Brave** |
| Gestor de contraseñas | **KeePassXC** |
| Bloqueo de pantalla | **i3lock-color** |
| Widgets / dashboards | **eww** |
| Wallpapers | **feh** (+ persistencia automática por tema) |
| Monitor de sistema | **btm** (bottom) |
| Docker | **lazydocker** (TUI) |

---

## 🎨 Temas (rices)

Se incluyen **3 temas**, cambiables en caliente con `Alt + Space`:

| Tema | Barra | Estilo |
|---|---|---|
| **emilia** | polybar | Tokyo Night (azul/morado) |
| **cristina** | polybar | Rosé Pine Moon |
| **h4ck3r** | polybar | verde "hacker" (muestra red/VPN/IP) |

Cada tema guarda su propio wallpaper y su propio esquema de colores (terminal,
bordes, GTK, iconos). El wallpaper **persiste tras reiniciar** automáticamente.

---

## ✅ Requisitos

- Una distro soportada (**Arch / Fedora / Debian / Ubuntu**) con sesión **X11**.
- Privilegios `sudo`.
- Conexión a internet (para descargar fuentes, temas y binarios).
- En Fedora, el instalador habilita **RPM Fusion** automáticamente.

---

## 🚀 Instalación

> ⚠️ Revisa el script antes de ejecutarlo. Hace backup de tus configs previos en
> `~/.RiceBackup/<fecha>/`.

```bash
git clone <URL-de-tu-repo> fedora-bspwm-dotfiles
cd fedora-bspwm-dotfiles
chmod +x install.sh
./install.sh
```

El script:
1. Instala los paquetes de Fedora (`dnf`).
2. Descarga e instala fuentes (JetBrainsMono Nerd Font + iconos).
3. Descarga los temas GTK / iconos / cursor de gh0stzk.
4. Compila **eww** e **i3lock-color** (necesitan Rust/C).
5. Instala binarios (**yazi**, **lazydocker**, **Neovim 0.12**).
6. Copia los dotfiles a `~/.config` y `~/`.
7. Clona los plugins de zsh y pone zsh como shell de login.

Al terminar: cierra sesión → elige **bspwm** en la pantalla de login.

---

## 📦 Paquetes instalados

> Los nombres de abajo son de **Fedora** como ejemplo. Para los nombres exactos en
> **Arch / Debian / Ubuntu / openSUSE**, consulta **[COMPONENTS.md](COMPONENTS.md)**
> (tabla completa por distro). El instalador usa el nombre correcto según tu sistema.

**Núcleo del entorno**
```
bspwm sxhkd polybar picom rofi dunst feh
```

**Terminales y shell**
```
kitty alacritty zsh zsh-autosuggestions zsh-syntax-highlighting
```

**Utilidades X11 / captura / control**
```
maim xclip xdotool brightnessctl xsetroot xrandr xprop xwininfo
xdpyinfo xkill xrdb xsettingsd pamixer playerctl redshift
```

**Apps y herramientas**
```
Thunar tumbler gvfs-mtp geany jgmenu ImageMagick jq libwebp
mpv pavucontrol keepassxc lxsession polkit-gnome
```

**CLI modernas**
```
bat bc eza fzf ripgrep bottom inotify-tools
```

**Iconos / soporte**
```
papirus-icon-theme python3-gobject xdg-user-dirs webp-pixbuf-loader
```

**Fuentes (repos)**
```
jetbrains-mono-fonts-all levien-inconsolata-fonts
```

**Dependencias de compilación** (para eww e i3lock-color)
```
cargo rust git gtk3-devel glib2-devel cairo-devel cairo-gobject-devel
pango-devel gdk-pixbuf2-devel gtk-layer-shell-devel libdbusmenu-devel
libdbusmenu-gtk3-devel autoconf automake pkgconf-pkg-config make gcc
libxcb-devel xcb-util-devel xcb-util-image-devel xcb-util-xrm-devel
xcb-util-keysyms-devel xcb-util-cursor-devel libxkbcommon-devel
libxkbcommon-x11-devel pam-devel libX11-devel libev-devel
libjpeg-turbo-devel giflib-devel libpng-devel
```

---

## 🔧 Instalado/compilado a mano

Estos **no están en los repos de Fedora**; el `install.sh` los resuelve:

| Herramienta | Método | Ubicación |
|---|---|---|
| **eww** | compilado con `cargo` (backend X11) | `~/.local/bin/eww` |
| **i3lock-color** | compilado (autotools) | `/usr/local/bin/i3lock` |
| **yazi** | binario oficial (GitHub releases) | `~/.local/bin/yazi` |
| **lazydocker** | binario oficial (GitHub releases) | `~/.local/bin/lazydocker` |
| **Neovim 0.12** | tarball oficial (config usa `vim.pack`, requiere ≥0.12) | `/opt/nvim-0.12` → `/usr/local/bin/nvim` |
| plugins zsh | `git clone` (fzf-tab, zsh-history-substring-search) | `~/.config/zsh/plugins/` |

> El Neovim de Fedora (0.11.x) queda intacto en `/usr/bin/nvim`.

---

## 🔤 Fuentes

- **JetBrainsMono Nerd Font** — fuente principal (descarga de nerd-fonts).
- Fuentes de **iconos** (de gh0stzk): Font Awesome 6, Material Design Icons,
  Phosphor, Iosevka NF, MesloLGS NF, Cozette, scientifica, CartographCF, etc.
- **Inconsolata** (repo Fedora).

Se instalan en `~/.local/share/fonts/`.

---

## 🖼️ Temas GTK, iconos y cursor

Descargados de los paquetes de gh0stzk (`gh0stzk.github.io/pkgs`) y extraídos a
`~/.local/share/themes` y `~/.local/share/icons`:

- **Temas GTK**: TokyoNight-zk, RosePineMoon-zk, h4ck3r-zk, Decayce-zk (los que usan los 4 rices).
- **Iconos**: TokyoNight-SE, Catppuccin-Mocha, Hack, Luv-Folders.
- **Cursor**: Qogirr-Dark.

---

## 🔁 Adaptaciones multi-distro

El original de gh0stzk es solo para Arch. Aquí se generalizó para cualquier distro:

| Original (Arch) | Ahora (universal) |
|---|---|
| `lxpolkit` | detecta el agente polkit disponible (lxpolkit / GNOME / KDE) |
| `checkupdates` / `paru` (módulo Updates) | **detecta el gestor**: `checkupdates` / `dnf` / `apt` |
| `paru -Syu` (acción actualizar) | script `SysUpdate` que **detecta el gestor** (pacman/dnf/apt/zypper) |
| aliases `reflector`, `grub-mkconfig` | aliases `update`/`refresh` **según el gestor** detectado |
| rutas de plugins zsh de Arch | clonados en `~/.config/zsh/plugins` (igual en toda distro) |
| paquetes AUR (eww, i3lock-color) | compilados desde código (igual en toda distro) |
| `clipcat` (portapapeles) | protegido con `command -v` (opcional) |

Toda la lógica dependiente de distro vive en `install.sh` (mapa de paquetes) y en
3 scripts que **detectan el gestor en runtime** (`SysUpdate`, `Updates`, `.zshrc`).

---

## ⭐ Personalizaciones propias

Cambios hechos sobre el rice base:

- **Bordes de nodo**: solo la ventana **enfocada** tiene borde (azul apagado, 2px,
  distinto por tema desde su paleta). Las no enfocadas: borde = color de fondo
  (invisible). Con **una sola ventana no hay borde** (`borderless_monocle`).
- **Wallpaper persistente por tema**: script **`WallWatch`** (inotify) que guarda
  automáticamente el fondo actual en el `DEFAULT_WALL` del rice activo. El selector
  de temas (`Alt+Space`) muestra el wallpaper actual de cada rice, no el estático.
- **Módulo de IP** en la barra: muestra la IP local, actualizada cada 2s (en z0mbi3
  va en el tooltip del wifi por ser barra vertical).
- **Barras limpiadas**: quitados módulos de música (mpd/mplayer) y bluetooth; en
  emilia también el color-picker.
- **Iconos**: logo de **Tux** (en vez de Arch) en el launcher, en amarillo Tux;
  logo de **Fedora** en el prompt de la terminal.
- **Atajos**: cheatsheet en `super + c`; navegador = **Brave**; `super + k` =
  **KeePassXC**; teclas especiales del teclado (calculadora, captura, bloqueo,
  mute mic) mapeadas.
- **Eliminados**: rices `andrea` y `z0mbi3`; toda la infra de música (`mpd`/`mpc`/
  `ncmpcpp` + widget de música de eww), `cava`, terminal `ghostty`, wallpapers
  animados (`AnimatedWall`), gestor de contraseñas `RofiPass`,
  Android Mount y Clipboard (dependían de paquetes AUR).
- **picom**: duraciones de animación equilibradas (más ágil sin ser brusco).
- **Terminal (zsh)**: copiar/pegar con `Ctrl+C`/`Ctrl+V` en kitty; `ls` detallado
  a color con eza; tema de terminal distinto por rice.

---

## ⌨️ Atajos de teclado

`super` = tecla Windows. Definidos en `~/.config/bspwm/config/sxhkdrc`.
Ver la **cheatsheet completa** en el escritorio con **`super + c`**.

| Atajo | Acción |
|---|---|
| `super + Return` | Terminal (kitty) |
| `super + Space` | Menú de apps (rofi) |
| `Alt + Space` | Selector de temas |
| `super + c` | Hoja de atajos (cheatsheet) |
| `super + b` / `e` / `f` | Brave / editor / gestor de archivos |
| `super + y` / `v` | yazi / Neovim |
| `super + k` | KeePassXC |
| `super + w` | (varía) — ver sxhkdrc |
| `super + x` / `super + shift + x` | cerrar / matar nodo |
| `super + 1-9,0` | cambiar de escritorio |
| `super + alt + w` | selector de wallpaper |
| `super + alt + r` | reiniciar bspwm |
| Teclas multimedia | volumen, brillo, calculadora, captura (Print), bloqueo |

---

## ⚙️ Configuración tras instalar

Algunos módulos necesitan datos propios de cada usuario:

- **Interfaz de red / batería / brillo**: se autodetectan al iniciar sesión
  (`SetSysVars`). Si tu equipo es de escritorio, los módulos de batería/brillo
  simplemente no mostrarán datos.

- **Wallpaper**: elige el tuyo con `super + alt + w`; se guarda solo por tema.

- **Bloqueo de pantalla** (i3lock-color) y **cheatsheet/tarjeta de perfil** (eww):
  requieren compilar `i3lock-color` y `eww` (opción durante `install.sh`). Los 3
  temas funcionan sin ellos; solo faltarían esas utilidades.

## 🙏 Créditos

- Basado en **[gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles)** (GPL-3.0).
- Temas GTK/iconos/cursor y fuentes de iconos: gh0stzk.
- Adaptación a Fedora y personalizaciones: este repo.

Licencia: **GPL-3.0** (heredada del proyecto original).
