#!/usr/bin/env bash
#
# install.sh — установка OpenMoHAA (Medal of Honor: Allied Assault) на Raspberry Pi (aarch64)
#
# Использование:
#   ./install.sh "/путь/к/игре"     папка с установленной MoHAA (внутри есть main/)
#                                    или сама папка main
#   ./install.sh                     только движок, данные положите в <DEST>/main позже
#
# Переменные окружения:
#   VERSION  версия OpenMoHAA          (по умолчанию 0.82.1)
#   DEST     куда ставить              (по умолчанию ~/openmohaa-v<VERSION>-linux-arm64)
#   SCREEN   разрешение полного экрана (по умолчанию — текущий режим экрана, иначе 1024x600)
#
set -euo pipefail

VERSION="${VERSION:-0.82.1}"
DEST="${DEST:-$HOME/openmohaa-v$VERSION-linux-arm64}"
DATA_SRC="${1:-}"
ASSET="openmohaa-v$VERSION-linux-arm64.zip"
URL="https://github.com/openmoh/openmohaa/releases/download/v$VERSION/$ASSET"

say()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# --- 1. Платформа ------------------------------------------------------------
say "Проверка платформы"
[ "$(uname -m)" = aarch64 ] || die "Нужна 64-битная ОС (aarch64)"
echo "    $(tr -d '\0' < /proc/device-tree/model 2>/dev/null || echo unknown)"
for t in curl rsync; do command -v $t >/dev/null || die "Не найден $t: sudo apt install $t"; done

# --- 2. Движок ---------------------------------------------------------------
say "Движок OpenMoHAA $VERSION -> $DEST"
if [ -x "$DEST/openmohaa" ]; then
    echo "    уже установлен"
else
    TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
    curl -fL --progress-bar -o "$TMP/$ASSET" "$URL" || die "Не удалось скачать $URL"
    mkdir -p "$DEST"
    if command -v unzip >/dev/null; then
        unzip -oq "$TMP/$ASSET" -d "$DEST"
    else
        python3 -I -m zipfile -e "$TMP/$ASSET" "$DEST"
    fi
fi
# в архиве у файлов нет прав на запуск
chmod +x "$DEST"/openmohaa "$DEST"/omohaaded "$DEST"/launch_openmohaa_*
echo "    $(ls "$DEST" | tr '\n' ' ')"

# --- 3. Данные игры ----------------------------------------------------------
if [ -n "$DATA_SRC" ]; then
    [ -d "$DATA_SRC" ] || die "Нет каталога: $DATA_SRC"
    if [ -d "$DATA_SRC/main" ]; then ROOT="$DATA_SRC"
    elif ls "$DATA_SRC"/*.pk3 >/dev/null 2>&1 || ls "$DATA_SRC"/*.PK3 >/dev/null 2>&1; then ROOT="$(dirname "$DATA_SRC")"
    else die "В $DATA_SRC нет ни папки main, ни файлов .pk3"; fi
    # main — оригинал, mainta — Spearhead, maintt — Breakthrough
    for d in main mainta maintt; do
        src=$(find "$ROOT" -maxdepth 1 -type d -iname "$d" | head -1)
        [ -n "$src" ] || continue
        say "Копирование $d (около 2 ГБ для main, может занять пару минут)"
        mkdir -p "$DEST/$d"
        rsync -a --info=progress2 --exclude='*.dll' --exclude='*.exe' "$src"/ "$DEST/$d"/
    done
fi

say "Проверка данных"
PK3=$(find "$DEST/main" -maxdepth 1 -iname '*.pk3' 2>/dev/null | wc -l)
echo "    архивов .pk3 в main: $PK3"
[ "$PK3" -gt 0 ] || warn "Данных нет: скопируйте Pak*.pk3, sound, video из папки main купленной игры в $DEST/main"
for d in mainta maintt; do [ -d "$DEST/$d" ] && echo "    найден аддон: $d"; done

# --- 4. Разрешение экрана ----------------------------------------------------
if [ -z "${SCREEN:-}" ]; then
    SCREEN=$(XDG_RUNTIME_DIR=/run/user/$(id -u) WAYLAND_DISPLAY=wayland-0 wlr-randr 2>/dev/null \
             | awk '/current/ {print $1; exit}')
    SCREEN="${SCREEN:-1024x600}"
fi
W="${SCREEN%x*}"; H="${SCREEN#*x}"
# если конфиг игры уже есть — поправить и в нём
CFG="$HOME/.openmohaa/main/configs/omconfig.cfg"
if [ -f "$CFG" ]; then
    sed -i -e 's/^seta r_fullscreen .*/seta r_fullscreen "1"/' -e 's/^seta r_mode .*/seta r_mode "-1"/' \
           -e "s/^seta r_customwidth .*/seta r_customwidth \"$W\"/" -e "s/^seta r_customheight .*/seta r_customheight \"$H\"/" "$CFG"
fi

# --- 5. Скрипт запуска -------------------------------------------------------
say "Скрипт запуска"
RUN="$DEST/run-mohaa.sh"
cat > "$RUN" <<EOF
#!/usr/bin/env bash
# Запуск OpenMoHAA во весь экран ${W}x${H}, отвязанно от терминала и SSH.
#   run-mohaa.sh            Allied Assault
#   run-mohaa.sh spearhead  аддон Spearhead (нужна папка mainta)
#   run-mohaa.sh breakthrough  аддон Breakthrough (нужны mainta и maintt)
GAME="\${1:-base}"; shift || true
cd "$DEST" || exit 1
# после pkill -9 остаётся pid-файл, и игра при старте спрашивает про «Abnormal Exit»
pgrep -x openmohaa >/dev/null || rm -f "\$HOME"/.openmohaa/*/OpenMoHAA.pid
DISPLAY="\${DISPLAY:-:0}" setsid nohup ./launch_openmohaa_\$GAME \\
    +set r_fullscreen 1 +set r_mode -1 +set r_customwidth $W +set r_customheight $H "\$@" \\
    > "\$HOME/mohaa.log" 2>&1 < /dev/null &
echo "Запущено. Лог: \$HOME/mohaa.log"
echo "Остановить: pkill -9 openmohaa   (без -9 движок может зависнуть при закрытии)"
EOF
chmod +x "$RUN"
echo "    $RUN"

say "Готово"
cat <<EOF

    Движок:  $DEST
    Запуск:  $RUN
    Выход:   через меню игры; если зависла — pkill -9 openmohaa

EOF
