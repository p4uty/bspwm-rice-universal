# 🧱 COMPONENTS.md — Componentes y equivalencias por distro

Documento técnico de **todos** los componentes que usa este rice de bspwm, su
**rol**, y el **nombre del paquete en cada distro**. Sirve para:

- Entender qué hace cada pieza.
- Instalar manualmente en cualquier distro.
- Portar el `install.sh` a una distro nueva (basta añadir un bloque al `case`).

> Los **archivos de configuración** (`.config/*`) son **idénticos en todas las
> distros**. Lo único que cambia entre distros es **cómo se instalan los paquetes**.

---

## 1. Cómo detecta la distro el instalador

`install.sh` lee `/etc/os-release` (`ID` + `ID_LIKE`) y agrupa en **familias**:

| Familia | Distros | Gestor | Comando de instalación |
|---|---|---|---|
| `arch` | Arch, Manjaro, EndeavourOS, Artix… | pacman | `pacman -S --needed` |
| `fedora` | Fedora, RHEL, Nobara… | dnf | `dnf install --skip-unavailable` |
| `debian` | Debian, Ubuntu, Mint, Pop!_OS… | apt | `apt-get install` |
| `suse` | openSUSE (Tumbleweed/Leap) | zypper | `zypper install` |

En Debian/apt y Arch/pacman los paquetes se instalan **uno a uno** para que uno
ausente no aborte todo (se avisa con `[!]`).

---

## 2. Paquetes del sistema (por distro)

Rol → nombre del paquete. `—` = no está en repos oficiales (ver §3/§5).

| Componente | Rol | Arch | Fedora | Debian/Ubuntu | openSUSE |
|---|---|---|---|---|---|
| **bspwm** | window manager | `bspwm` | `bspwm` | `bspwm` | `bspwm` |
| **sxhkd** | atajos de teclado | `sxhkd` | `sxhkd` | `sxhkd` | `sxhkd` |
| **polybar** | barra | `polybar` | `polybar` | `polybar` | `polybar` |
| **picom** | compositor | `picom` | `picom` | `picom` | `picom` |
| **rofi** | lanzador/menús | `rofi` | `rofi` | `rofi` | `rofi` |
| **dunst** | notificaciones | `dunst` | `dunst` | `dunst` | `dunst` |
| **feh** | wallpaper | `feh` | `feh` | `feh` | `feh` |
| **kitty** | terminal | `kitty` | `kitty` | `kitty` | `kitty` |
| **alacritty** | terminal alt | `alacritty` | `alacritty` | `alacritty` | `alacritty` |
| **zsh** | shell | `zsh` | `zsh` | `zsh` | `zsh` |
| autosuggestions | plugin zsh | `zsh-autosuggestions` | `zsh-autosuggestions` | `zsh-autosuggestions` | (manual) |
| syntax-highlighting | plugin zsh | `zsh-syntax-highlighting` | `zsh-syntax-highlighting` | `zsh-syntax-highlighting` | (manual) |
| **maim** | captura | `maim` | `maim` | `maim` | `maim` |
| **xclip** | portapapeles X | `xclip` | `xclip` | `xclip` | `xclip` |
| **xdotool** | automatización X | `xdotool` | `xdotool` | `xdotool` | `xdotool` |
| **brightnessctl** | brillo | `brightnessctl` | `brightnessctl` | `brightnessctl` | `brightnessctl` |
| xsetroot/xrandr/xrdb | utilidades X | `xorg-xsetroot` `xorg-xrandr` `xorg-xrdb` | `xsetroot` `xrandr` `xrdb` | `x11-xserver-utils` | `xsetroot` `xrandr` `xrdb` |
| xprop/xwininfo/xdpyinfo/xkill | utilidades X | `xorg-xprop` … | `xprop` `xwininfo` `xdpyinfo` `xkill` | `x11-utils` | idem Fedora |
| **xsettingsd** | ajustes GTK/X | `xsettingsd` | `xsettingsd` | `xsettingsd` | `xsettingsd` |
| **pamixer** | volumen | `pamixer` | `pamixer` | `pamixer` | `pamixer` |
| **playerctl** | control media | `playerctl` | `playerctl` | `playerctl` | `playerctl` |
| **redshift** | luz nocturna | `redshift` | `redshift` | `redshift` | `redshift` |
| **Thunar** | gestor archivos GUI | `thunar` | `Thunar` | `thunar` | `thunar` |
| **tumbler** | miniaturas | `tumbler` | `tumbler` | `tumbler` | `tumbler` |
| gvfs-mtp | montaje MTP | `gvfs-mtp` | `gvfs-mtp` | `gvfs-backends` | `gvfs` |
| **geany** | editor GUI | `geany` | `geany` | `geany` | `geany` |
| **jgmenu** | menú clic derecho | `jgmenu` | `jgmenu` | `jgmenu` | `jgmenu` |
| **ImageMagick** | procesar imágenes | `imagemagick` | `ImageMagick` | `imagemagick` | `ImageMagick` |
| **jq** | parsear JSON | `jq` | `jq` | `jq` | `jq` |
| libwebp / webp | soporte WebP | `libwebp` | `libwebp` | `webp` | (incluido) |
| webp-pixbuf-loader | WebP en GTK/rofi | `webp-pixbuf-loader` | `webp-pixbuf-loader` | `webp-pixbuf-loader` | (manual) |
| **mpv** | reproductor | `mpv` | `mpv` | `mpv` | `mpv` |
| **pavucontrol** | mezclador audio | `pavucontrol` | `pavucontrol` | `pavucontrol` | `pavucontrol` |
| **keepassxc** | gestor contraseñas | `keepassxc` | `keepassxc` | `keepassxc` | `keepassxc` |
| lxsession | provee `lxpolkit` | `lxsession` | `lxsession` | `lxsession` | `lxsession` |
| polkit-gnome | agente polkit | `polkit-gnome` | `polkit-gnome` | `policykit-1-gnome` | `polkit-gnome` |
| **bat** | `cat` con color | `bat` | `bat` | `bat` (`batcat`) | `bat` |
| **bc** | calculadora shell | `bc` | `bc` | `bc` | `bc` |
| **eza** | `ls` moderno | `eza` | `eza` | — (binario, §3) | — (binario) |
| **fzf** | fuzzy finder | `fzf` | `fzf` | `fzf` | `fzf` |
| **ripgrep** | grep rápido | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` |
| **bottom** (`btm`) | monitor sistema | `bottom` | `bottom` | — (binario, §3) | — (binario) |
| inotify-tools | vigilar archivos (WallWatch) | `inotify-tools` | `inotify-tools` | `inotify-tools` | `inotify-tools` |
| papirus-icon-theme | iconos GTK | `papirus-icon-theme` | `papirus-icon-theme` | `papirus-icon-theme` | `papirus-icon-theme` |
| python-gobject | scripts eww/rofi | `python-gobject` | `python3-gobject` | `python3-gi` | `python3-gobject` |
| xdg-user-dirs | carpetas usuario | `xdg-user-dirs` | `xdg-user-dirs` | `xdg-user-dirs` | `xdg-user-dirs` |
| JetBrains Mono | fuente base | `ttf-jetbrains-mono` | `jetbrains-mono-fonts-all` | `fonts-jetbrains-mono` | (binario, §4) |
| Inconsolata | fuente | `ttf-inconsolata` | `levien-inconsolata-fonts` | `fonts-inconsolata` | (manual) |

---

## 3. CLI que puede faltar en Debian/openSUSE

`eza` y `bottom` no siempre están en repos (sobre todo Debian estable/Ubuntu LTS).
El `install.sh` los instala como **binario oficial** en `~/.local/bin/` **solo si
no existen** ya como paquete:

- **eza** → [eza-community/eza](https://github.com/eza-community/eza/releases) (`*-x86_64-unknown-linux-gnu.tar.gz`)
- **bottom** (`btm`) → [ClementTsang/bottom](https://github.com/ClementTsang/bottom/releases)

---

## 4. Componentes que NO están en repos (universales)

Se resuelven igual en **todas** las distros (compilar o binario oficial):

| Componente | Rol | Método | Requisito |
|---|---|---|---|
| **eww** | widgets: cheatsheet (`super+c`) y tarjeta de perfil | compilar (`cargo`, backend X11) | dependencias `BUILD` |
| **i3lock-color** | bloqueo de pantalla con blur | compilar (autotools) | dependencias `BUILD` |
| **yazi** (`yazi`+`ya`) | gestor de archivos TUI | binario oficial → `~/.local/bin` | — |
| **lazydocker** | gestor Docker TUI | binario oficial → `~/.local/bin` | — |
| **Neovim 0.12** | editor (config usa `vim.pack`, requiere ≥0.12) | tarball oficial → `/opt/nvim-0.12` + symlink | — |
| **JetBrainsMono Nerd Font** | fuente principal (glifos/iconos) | descarga de nerd-fonts | — |
| Fuentes de iconos | Font Awesome, Material Design, Phosphor… | **incluidas** en `assets/fonts/` | — |
| Temas GTK `*-zk` | apariencia GTK por tema | descarga `gh0stzk.github.io/pkgs` | — |
| Iconos `TokyoNight-SE`, `Catppuccin-Mocha`, `Hack` | iconos por tema | descarga `gh0stzk.github.io/pkgs` | — |
| Cursor `Qogirr-Dark` | cursor | descarga `gh0stzk.github.io/pkgs` | — |

> El **`eww`** y el **`i3lock-color`** solo se compilan si respondes `y` a la
> pregunta del instalador. Los 3 temas usan **polybar**; `eww` se usa solo para la
> **cheatsheet** (`super+c`) y la tarjeta de perfil — sin `eww` esas dos cosas no
> aparecen, pero los temas funcionan. Sin `i3lock-color`, no hay bloqueo de pantalla.

---

## 5. Notas y limitaciones por distro

- **Arch**: es la distro de origen (gh0stzk). `eww`, `i3lock-color`, `xwinwrap`
  también están en AUR; si usas un helper (paru/yay) puedes instalarlos desde ahí
  en vez de compilar.
- **Fedora**: requiere **RPM Fusion** (el instalador lo habilita). Es la distro de
  referencia probada.
- **Debian/Ubuntu**:
  - `eza` y `bottom` se instalan como binario (§3).
  - `feh`+WebP: si los wallpapers `.webp` no cargan, instala un `libimlib2` con
    soporte WebP o convierte los wallpapers a `.jpg`.
  - El nombre del agente polkit puede variar (`policykit-1-gnome` /
    `polkit-1-auth-agent-gnome` según versión).
  - `polybar`/`alacritty` requieren Debian 12+ o Ubuntu 22.04+.
- **openSUSE**: soporte básico; algunos plugins de zsh y `webp-pixbuf-loader` puede
  que haya que instalarlos a mano.

---

## 6. Añadir soporte a una distro nueva

En `install.sh`, dentro del `case "$FAMILY"`, añade un bloque con:

```sh
tudistro)
  PM_UP="<comando para refrescar índices>"
  PM_IN="<comando para instalar>"
  RUNTIME="<lista de paquetes de la tabla §2 con los nombres de tu distro>"
  BUILD="<dependencias de compilación para eww/i3lock-color>" ;;
```

y añade su `ID`/`ID_LIKE` al `case` de detección al inicio. El resto del script
(fuentes, temas, binarios, configs) ya es universal.

---

## 7. Archivos de configuración clave

| Archivo | Qué controla |
|---|---|
| `.config/bspwm/bspwmrc` | arranque, reglas, autostart (incluye `dunst`, `WallWatch`) |
| `.config/bspwm/config/sxhkdrc` | atajos de teclado |
| `.config/bspwm/rices/<tema>/` | cada tema: colores, wallpaper, barra |
| `.config/bspwm/bin/` | scripts (Theme.sh, WallSelect, WallWatch, SysUpdate…) |
| `.config/bspwm/bin/SysUpdate` | actualizar sistema (**detecta el gestor**) |
| `.config/bspwm/bin/Updates` | contador de actualizaciones en la barra (**multi-distro**) |
| `home/.zshrc` | shell zsh (prompt, plugins, aliases **multi-distro**) |
