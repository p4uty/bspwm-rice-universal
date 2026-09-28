# 🧱 COMPONENTS.md: componentes y equivalencias por distro

Documento técnico con **todos** los componentes del rice: qué **rol** cumple cada
uno y **cómo se llama su paquete en cada distro**. Sirve para:

- Entender qué hace cada pieza.
- Instalar a mano en cualquier distro.
- Portar `install.sh` a una distro nueva (basta con añadir un bloque al `case`).

> Los **archivos de configuración** (`.config/*`) son **idénticos en todas las
> distros**. Lo único que cambia entre distros es **cómo se instalan los paquetes**.

Los nombres de esta tabla se comprobaron en los repositorios oficiales de
Arch (rolling), Fedora 43, Debian 12, Debian 13 y Ubuntu 24.04 con
`tests/run-tests.sh`. Para ver exactamente qué instalaría el script en tu
sistema, sin instalar nada:

```bash
./install.sh --print-packages
```

---

## 1. Cómo detecta la distro el instalador

`install.sh` lee `/etc/os-release` (`ID` + `ID_LIKE`) y agrupa las distros en **familias**:

| Familia | Distros | Gestor | Comando que usa |
|---|---|---|---|
| `arch` | Arch, EndeavourOS, Manjaro, Artix… | pacman | `pacman -Syu --needed` |
| `fedora` | Fedora, Nobara… | dnf | `dnf install --skip-unavailable` |
| `debian` | Debian, Ubuntu, Linux Mint, Pop!_OS… | apt | `apt-get install` |
| `suse` | openSUSE (Tumbleweed/Leap), **experimental, sin probar** | zypper | `zypper install` |

Primero instala todos los paquetes de golpe. Si falla (por ejemplo, porque un
nombre no existe en tu versión), reintenta **uno a uno** y avisa de los que
faltan con `[!]`. Al final muestra un resumen de avisos y comprueba que existan
los comandos necesarios.

> **Arch:** se usa `pacman -Syu`, así que el instalador **actualiza también el
> sistema**. En Arch no se deben hacer actualizaciones parciales (`-Sy` + `-S`).

---

## 2. Paquetes del sistema (por distro)

`—` = no está en los repos oficiales; se instala como binario (ver §3).

| Componente | Rol | Arch | Fedora | Debian / Ubuntu | openSUSE |
|---|---|---|---|---|---|
| **Xorg** | servidor gráfico X11 | `xorg-server` `xorg-xinit` | `xorg-x11-server-Xorg` `xorg-x11-xinit` | `xserver-xorg` `xinit` | `xorg-x11-server` `xinit` |
| **bspwm** | gestor de ventanas | `bspwm` | `bspwm` | `bspwm` | `bspwm` |
| **sxhkd** | atajos de teclado | `sxhkd` | `sxhkd` | `sxhkd` | `sxhkd` |
| **polybar** | barra | `polybar` | `polybar` | `polybar` | `polybar` |
| **picom** | compositor (sombras, transparencias, animaciones) | `picom` | `picom` | `picom` | `picom` |
| **rofi** | lanzador y menús | `rofi` | `rofi` | `rofi` | `rofi` |
| **dunst** | notificaciones (incluye `dunstify`) | `dunst` | `dunst` | `dunst` | `dunst` |
| **feh** | wallpaper | `feh` | `feh` | `feh` | `feh` |
| **kitty** | terminal | `kitty` | `kitty` | `kitty` | `kitty` |
| **alacritty** | terminal alternativa | `alacritty` | `alacritty` | `alacritty` | `alacritty` |
| **zsh** | shell | `zsh` | `zsh` | `zsh` | `zsh` |
| zsh-autosuggestions | plugin zsh | `zsh-autosuggestions` | `zsh-autosuggestions` | `zsh-autosuggestions` | (a mano) |
| zsh-syntax-highlighting | plugin zsh | `zsh-syntax-highlighting` | `zsh-syntax-highlighting` | `zsh-syntax-highlighting` | (a mano) |
| **maim** | capturas de pantalla | `maim` | `maim` | `maim` | `maim` |
| **xclip** | portapapeles X | `xclip` | `xclip` | `xclip` | `xclip` |
| **xdotool** | automatización X (scratchpad, jgmenu) | `xdotool` | `xdotool` | `xdotool` | `xdotool` |
| **brightnessctl** | brillo | `brightnessctl` | `brightnessctl` | `brightnessctl` | `brightnessctl` |
| xsetroot / xrandr / xrdb | utilidades X | `xorg-xsetroot` `xorg-xrandr` `xorg-xrdb` | `xsetroot` `xrandr` `xrdb` | `x11-xserver-utils` | `xsetroot` `xrandr` `xrdb` |
| xprop / xwininfo / xdpyinfo / xkill | utilidades X | `xorg-xprop` `xorg-xwininfo` `xorg-xdpyinfo` `xorg-xkill` | `xprop` `xwininfo` `xdpyinfo` `xkill` | `x11-utils` | igual que Fedora |
| setxkbmap | distribución de teclado (bloqueo, KeyBoardL) | `xorg-setxkbmap` | `setxkbmap` | `x11-xkb-utils` | `setxkbmap` |
| **xsettingsd** | ajustes GTK en caliente | `xsettingsd` | `xsettingsd` | `xsettingsd` | `xsettingsd` |
| **pamixer** | volumen | `pamixer` | `pamixer` | `pamixer` | `pamixer` |
| pactl | silenciar micrófono | `libpulse` | `pulseaudio-utils` | `pulseaudio-utils` | `pulseaudio-utils` |
| **playerctl** | control multimedia | `playerctl` | `playerctl` | `playerctl` | `playerctl` |
| **redshift** | luz nocturna | `redshift` | `redshift` | `redshift` | `redshift` |
| nmcli | menú de red (NetManagerDM) | `networkmanager` | `NetworkManager` | `network-manager` | `NetworkManager` |
| bluetoothctl | menú bluetooth | `bluez-utils` | `bluez` | `bluez` | `bluez` |
| checkupdates | contador de actualizaciones (Arch) | `pacman-contrib` | (usa `dnf`) | (usa `apt-get`) | — |
| **Thunar** | gestor de archivos gráfico | `thunar` | `Thunar` | `thunar` | `thunar` |
| **tumbler** | miniaturas | `tumbler` | `tumbler` | `tumbler` | `tumbler` |
| gvfs | montar móviles/USB | `gvfs-mtp` | `gvfs-mtp` | `gvfs-backends` | `gvfs` |
| **geany** | editor gráfico | `geany` | `geany` | `geany` | `geany` |
| **jgmenu** | menú del clic derecho | `jgmenu` | `jgmenu` | `jgmenu` | `jgmenu` |
| **ImageMagick** | procesar imágenes (wallpapers, bloqueo) | `imagemagick` | `ImageMagick` | `imagemagick` ¹ | `ImageMagick` |
| **jq** | procesar JSON | `jq` | `jq` | `jq` | `jq` |
| soporte WebP | wallpapers `.webp` | `libwebp` `webp-pixbuf-loader` | `libwebp` `webp-pixbuf-loader` | `webp` `webp-pixbuf-loader` | (a mano) |
| **mpv** | reproductor | `mpv` | `mpv` | `mpv` | `mpv` |
| **pavucontrol** | mezclador de audio | `pavucontrol` | `pavucontrol` | `pavucontrol` | `pavucontrol` |
| **keepassxc** | gestor de contraseñas | `keepassxc` | `keepassxc` | `keepassxc` | `keepassxc` |
| agente polkit | ventana que pide la contraseña de administrador en apps gráficas | `polkit-gnome` | `mate-polkit` | `lxpolkit` | `lxsession` |
| **bat** | `cat` con color | `bat` | `bat` | `bat` ² | `bat` |
| **bc** | calculadora de shell | `bc` | `bc` | `bc` | `bc` |
| **eza** | `ls` moderno | `eza` | `eza` | `eza` (Debian 13, Ubuntu) / — (Debian 12) | — |
| **fzf** | buscador difuso | `fzf` | `fzf` | `fzf` ³ | `fzf` ³ |
| **ripgrep** | grep rápido | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` |
| **bottom** (`btm`) | monitor del sistema | `bottom` | — | — | — |
| inotify-tools | vigilar archivos (WallWatch) | `inotify-tools` | `inotify-tools` | `inotify-tools` | `inotify-tools` |
| papirus-icon-theme | iconos GTK | `papirus-icon-theme` | `papirus-icon-theme` | `papirus-icon-theme` | `papirus-icon-theme` |
| python-gobject | scripts de red y RiceEditor | `python-gobject` | `python3-gobject` | `python3-gi` | `python3-gobject` |
| xdg-user-dirs | carpetas de usuario | `xdg-user-dirs` | `xdg-user-dirs` | `xdg-user-dirs` | `xdg-user-dirs` |
| JetBrains Mono | fuente base | `ttf-jetbrains-mono` | `jetbrains-mono-fonts-all` | `fonts-jetbrains-mono` | (Nerd Font, §4) |
| Inconsolata | fuente | `ttf-inconsolata` | `levien-inconsolata-fonts` | `fonts-inconsolata` | (a mano) |
| herramientas | descargas, extracción y red | `git curl unzip zstd tar fontconfig iproute2` | igual (`iproute`) | igual | igual |

¹ Debian 12 y Ubuntu 24.04 traen ImageMagick 6, que no tiene el comando `magick`.
El instalador crea `~/.local/bin/magick`, que llama a `convert`.
² En Debian/Ubuntu el binario se llama `batcat`. El instalador crea el enlace
`~/.local/bin/bat` y el `.zshrc` también lo tiene en cuenta.
³ El `.zshrc` y fzf-tab usan opciones de **fzf ≥ 0.58**. Si la versión de tu distro
es más antigua (Debian 12/13, Ubuntu 24.04), el instalador pone el binario oficial en `~/.local/bin/fzf`.

---

## 3. Binarios de respaldo (si la distro no los trae)

Se instalan como **binario oficial** en `~/.local/bin/`, y **solo si** el comando no existe ya:

| Herramienta | Cuándo | Origen |
|---|---|---|
| **eza** | Debian 12 | [eza-community/eza](https://github.com/eza-community/eza/releases) (build musl) |
| **bottom** (`btm`) | Fedora, Debian, Ubuntu | [ClementTsang/bottom](https://github.com/ClementTsang/bottom/releases) (build musl) |
| **fzf** | versión < 0.58 | [junegunn/fzf](https://github.com/junegunn/fzf/releases) |
| **Neovim** | versión < 0.12 | [neovim/neovim](https://github.com/neovim/neovim/releases) → `/opt/nvim`, enlace en `/usr/local/bin/nvim` |

---

## 4. Componentes que NO están en los repos (iguales en todas las distros)

| Componente | Rol | Método | Requisito |
|---|---|---|---|
| **yazi** (`yazi` + `ya`) | gestor de archivos en terminal | binario oficial (musl) → `~/.local/bin` | — |
| **lazydocker** | gestor de Docker en terminal | binario oficial → `~/.local/bin` | — |
| **eww** | widgets: hoja de atajos (`super+c`) y tarjeta de perfil | compilar (`cargo`, backend X11) → `~/.local/bin/eww` | `--build`, Rust ≥ 1.85 ⁴ |
| **i3lock-color** | bloqueo de pantalla con desenfoque | compilar (autotools) → `/usr/local/bin/i3lock` | `--build` |
| **JetBrainsMono Nerd Font** | fuente principal (glifos e iconos) | descarga de nerd-fonts → `~/.local/share/fonts` | — |
| Fuentes de iconos | Font Awesome, Material Design, Phosphor… | **incluidas** en `assets/fonts/` | — |
| Temas GTK `*-zk` | apariencia GTK de cada tema | descarga de `gh0stzk.github.io/pkgs` → `~/.local/share/themes` | — |
| Iconos `TokyoNight-SE`, `Catppuccin-Mocha`, `Hack` | iconos de cada tema | descarga de `gh0stzk.github.io/pkgs` → `~/.local/share/icons` | — |
| Cursor `Qogirr-Dark` | cursor | descarga de `gh0stzk.github.io/pkgs` → `~/.local/share/icons` | — |
| fzf-tab, zsh-history-substring-search | plugins de zsh | `git clone` → `~/.config/zsh/plugins` | — |

⁴ Si el Rust de tu distro es más antiguo, el instalador usa **rustup** en `~/.cargo`
(solo para tu usuario, sin tocar el sistema). Es el caso de Debian 12.

> **eww** e **i3lock-color** solo se compilan con `--build` (o si respondes `y`).
> Los 3 temas usan **polybar**, así que funcionan sin ellos. Solo faltarán la hoja de
> atajos (`super+c`), la tarjeta de perfil y el bloqueo de pantalla.
> En Arch también puedes instalarlos desde AUR (`eww`, `i3lock-color`) con paru o yay.

---

## 5. Notas y limitaciones por distro

- **Arch**: es la distro de origen del rice (gh0stzk). Todos los paquetes están en los
  repos oficiales. El instalador ejecuta `pacman -Syu`, lo que actualiza el sistema.
- **Fedora**: todo está en los repos oficiales; no hace falta RPM Fusion.
  `bottom` no está empaquetado, así que se instala como binario. El `lxpolkit` de
  Fedora no incluye el ejecutable, así que se usa el agente de MATE (`mate-polkit`).
- **Debian 12 / Ubuntu 24.04**:
  - Traen **picom 9.1** (Debian 12) y **picom 10** (Ubuntu 24.04), que no tienen el
    sistema de animaciones de picom 12+. picom arranca y aplica sombras y
    transparencias, pero **sin animaciones**.
  - Debian 12 trae polybar 3.6; el resto, 3.7.
  - `fzf`, `eza` (solo Debian 12) y Neovim se sustituyen por binarios oficiales (§3).
  - ImageMagick 6: se crea el comando `magick` de compatibilidad (§2).
- **Debian 13**: trae picom 12.5 (con animaciones). `fzf` y Neovim se sustituyen por binarios.
- **Ubuntu**: el instalador activa el repositorio `universe` si hace falta.
- **openSUSE**: soporte **experimental**. No se prueba automáticamente; algunos
  plugins de zsh y `webp-pixbuf-loader` pueden requerir instalación manual.
- **Solo x86_64**: los temas de gh0stzk y los binarios descargados son para x86_64.
- **Solo X11**: bspwm no funciona en Wayland. Tu gestor de login (GDM, SDDM,
  LightDM…) debe poder iniciar sesiones X11.

---

## 6. Añadir soporte a una distro nueva

En `install.sh`, añade un bloque dentro de `case "$FAMILY"`:

```sh
tudistro)
  PM_UP="<comando para refrescar índices>"
  PM_IN="<comando para instalar sin preguntar>"
  RUNTIME="<paquetes de la tabla §2 con los nombres de tu distro>"
  BUILD="<dependencias de compilación de eww/i3lock-color>" ;;
```

y añade su `ID`/`ID_LIKE` al `case` de detección del principio. El resto del
script (fuentes, temas, binarios, configs) ya es universal. Para probarlo, añade la
imagen de contenedor a `tests/run-tests.sh` (ver [README → Pruebas](README.md#-pruebas-automáticas)).

---

## 7. Archivos de configuración clave

| Archivo | Qué controla |
|---|---|
| `.config/bspwm/bspwmrc` | arranque de la sesión: reglas y autostart (sxhkd, dunst, picom, polkit, WallWatch) |
| `.config/bspwm/config/sxhkdrc` | atajos de teclado |
| `.config/bspwm/config/system.ini` | red, batería y brillo para la barra (lo rellena `SetSysVars` en el primer inicio) |
| `.config/bspwm/config/picom/` | compositor: sombras, esquinas, animaciones y reglas |
| `.config/bspwm/rices/<tema>/theme-config.bash` | colores, wallpaper, bordes y opacidad de cada tema |
| `.config/bspwm/rices/<tema>/config.ini` y `modules.ini` | polybar de cada tema |
| `.config/bspwm/config/modules/*.sh` | aplican el tema activo a cada app (kitty, rofi, dunst, GTK, nvim…) |
| `.config/bspwm/bin/` | scripts: Theme.sh, RiceSelector, WallSelect, WallWatch, PowerMenu, ScreenShoTer… |
| `.config/bspwm/bin/SysUpdate` | actualizar el sistema (**detecta el gestor de paquetes**) |
| `.config/bspwm/bin/Updates` | contador de actualizaciones de la barra (**multi-distro**) |
| `.config/bspwm/bin/OpenApps` | apps de cada atajo (navegador, calculadora… usa la primera que encuentra) |
| `home/.zshrc` | zsh: prompt, plugins y aliases **multi-distro** |
