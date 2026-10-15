#!/usr/bin/env bash
#
# install.sh — сборка и установка Serious Sam Classic: The First Encounter
#              на Raspberry Pi (aarch64, Raspberry Pi OS / Debian 13) из исходников
#              порта tx00100xt с исправлением угла обзора для нестандартных экранов.
#
# Использование:
#   ./install.sh                         собрать и установить движок
#   ./install.sh /путь/к/данным/игры     + скопировать данные купленной игры
#
# Переменные окружения:
#   GAME    папка игры           (по умолчанию ~/serioussam/aarch64/SamTFE)
#   SRC     папка исходников     (по умолчанию ~/ssc-src)
#   REPO    репозиторий порта    (по умолчанию https://github.com/tx00100xt/SeriousSamClassic.git)
#   SCREEN  разрешение игры      (по умолчанию — текущий режим экрана, иначе 1024x600)
#
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
GAME="${GAME:-$HOME/serioussam/aarch64/SamTFE}"
SRC="${SRC:-$HOME/ssc-src}"
REPO="${REPO:-https://github.com/tx00100xt/SeriousSamClassic.git}"
DATA_SRC="${1:-}"
USERDIR="$HOME/.local/share/Serious-Engine/serioussam"
DEPS=(git cmake make g++ bison flex rsync pkg-config libsdl2-dev libvorbis-dev libogg-dev zlib1g-dev)

say()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

# --- 1. Платформа ------------------------------------------------------------
say "Проверка платформы"
[ "$(uname -m)" = aarch64 ] || die "Нужна 64-битная ОС (aarch64)"
echo "    $(tr -d '\0' < /proc/device-tree/model 2>/dev/null || echo unknown)"

# --- 2. Зависимости для сборки -----------------------------------------------
say "Зависимости"
MISSING=()
for p in "${DEPS[@]}"; do
    case "$p" in g++|make|git|cmake|bison|flex|rsync|pkg-config)
        command -v "$p" >/dev/null || MISSING+=("$p") ;;
    *)  dpkg -s "$p" >/dev/null 2>&1 || MISSING+=("$p") ;;
    esac
done
if [ ${#MISSING[@]} -gt 0 ]; then
    echo "    не хватает: ${MISSING[*]}"
    sudo apt-get update
    sudo apt-get install -y "${MISSING[@]}"
else
    echo "    всё на месте"
fi

# --- 3. Исходники ------------------------------------------------------------
say "Исходники: $SRC"
if [ -d "$SRC/.git" ]; then
    echo "    уже скачаны ($(git -C "$SRC" log -1 --format='%h %ad' --date=short))"
else
    git clone --depth 1 "$REPO" "$SRC"
fi

# --- 4. Исправление угла обзора (см. README, фикс №1) ------------------------
say "Исправление SetAdjusters() для любых пропорций экрана"
F="$SRC/SamTFE/Sources/SeriousSam/SeriousSam.cpp"
if grep -q 'ratio >= 1.69f && ratio < 2.05f' "$F"; then
    echo "    уже применено"
elif patch -d "$SRC" -p1 --forward --dry-run < "$HERE/aspect-ratio-fix.patch" >/dev/null 2>&1; then
    patch -d "$SRC" -p1 --forward < "$HERE/aspect-ratio-fix.patch" >/dev/null
    echo "    применено (patch)"
else
    die "Патч не накладывается — исходники порта изменились. Поправьте условия в SetAdjusters() вручную (README, фикс №1)"
fi

# --- 5. Сборка ---------------------------------------------------------------
say "Сборка (около 7 минут на Pi 5)"
B="$SRC/build-tfe"
mkdir -p "$B"
cmake --fresh -S "$SRC/SamTFE/Sources" -B "$B" -DTFE=TRUE -DCMAKE_BUILD_TYPE=Release > "$B.cmake.log" 2>&1 \
    || { tail -20 "$B.cmake.log"; die "cmake завершился с ошибкой, лог: $B.cmake.log"; }
( cd "$B" && make ecc && make -j"$(nproc)" && make install ) > "$B.make.log" 2>&1 \
    || { grep -E "error" "$B.make.log" | head -20; die "Сборка упала, лог: $B.make.log"; }
echo "    готово, лог: $B.make.log"

# --- 6. Установка в папку игры -----------------------------------------------
say "Установка в $GAME"
mkdir -p "$GAME"
if [ -d "$GAME/Bin" ] && [ ! -d "$GAME/../backup-Bin" ]; then
    cp -a "$GAME/Bin" "$GAME/../backup-Bin"
    echo "    прежний Bin сохранён в $(cd "$GAME/.." && pwd)/backup-Bin"
fi
# служебные файлы порта (скрипты, управление и т.п.) — без перезаписи существующих
rsync -a --ignore-existing --exclude=Sources --exclude=Bin "$SRC/SamTFE/" "$GAME/"
# движок и его архив — всегда свежие
mkdir -p "$GAME/Bin"
cp -a "$SRC/SamTFE/Bin/." "$GAME/Bin/"
cp -a "$SRC/SamTFE/SE1_10b.gro" "$GAME/"

# --- 7. Данные игры (см. README, фикс №2) ------------------------------------
if [ -n "$DATA_SRC" ]; then
    [ -d "$DATA_SRC" ] || die "Нет каталога с данными: $DATA_SRC"
    say "Копирование данных игры из $DATA_SRC"
    rsync -a --info=progress2 --ignore-existing \
        --exclude=Bin/ --exclude='*.exe' --exclude='unins*' --exclude='*.log' \
        --exclude=Temp/ --exclude=Scripts/PersistentSymbols.ini \
        "$DATA_SRC"/ "$GAME"/
fi
GRO=$(find "$GAME" -maxdepth 1 -iname '*.gro' | wc -l)
echo "    архивов .gro: $GRO"
[ "$GRO" -ge 5 ] || warn "Данных игры нет или мало. Нужны *.gro и папка Levels из купленной игры (GOG/Steam/CD)"

# --- 8. Настройки экрана -----------------------------------------------------
say "Настройки экрана"
if [ -z "${SCREEN:-}" ]; then
    SCREEN=$(XDG_RUNTIME_DIR=/run/user/$(id -u) WAYLAND_DISPLAY=wayland-0 wlr-randr 2>/dev/null \
             | awk '/current/ {print $1; exit}')
    SCREEN="${SCREEN:-1024x600}"
fi
W="${SCREEN%x*}"; H="${SCREEN#*x}"
mkdir -p "$USERDIR/Scripts"
PS="$USERDIR/Scripts/PersistentSymbols.ini"
if [ -f "$PS" ] && ! grep -q 'ogl_bExclusive' "$PS"; then
    sed -i -e "s/sam_bFullScreen=(INDEX)[0-9]*/sam_bFullScreen=(INDEX)1/" \
           -e "s/sam_iScreenSizeI=(INDEX)[0-9]*/sam_iScreenSizeI=(INDEX)$W/" \
           -e "s/sam_iScreenSizeJ=(INDEX)[0-9]*/sam_iScreenSizeJ=(INDEX)$H/" "$PS"
    echo "    обновлён $PS"
else
    [ -f "$PS" ] && mv "$PS" "$PS.windows-bak" && warn "Файл настроек от Windows-версии отложен в $PS.windows-bak"
    printf 'persistent extern INDEX sam_bFullScreen=(INDEX)1;\npersistent extern INDEX sam_iScreenSizeI=(INDEX)%s;\npersistent extern INDEX sam_iScreenSizeJ=(INDEX)%s;\n' "$W" "$H" > "$PS"
    echo "    создан $PS"
fi
echo "    полный экран ${W}x${H}"

# --- 9. Скрипт запуска (см. README, фиксы №3 и №4) ---------------------------
RUN="$(cd "$GAME/.." && pwd)/run-tfe.sh"
cat > "$RUN" <<EOF
#!/usr/bin/env bash
# Запуск Serious Sam: The First Encounter напрямую через Wayland,
# отвязанно от терминала и SSH. Лог: ~/serioussam-tfe.log
cd "$GAME" || exit 1
XDG_RUNTIME_DIR="\${XDG_RUNTIME_DIR:-/run/user/\$(id -u)}" WAYLAND_DISPLAY="\${WAYLAND_DISPLAY:-wayland-0}" \\
    SDL_VIDEODRIVER=wayland setsid nohup ./Bin/SeriousSam "\$@" > "\$HOME/serioussam-tfe.log" 2>&1 < /dev/null &
echo "Запущено. Лог: \$HOME/serioussam-tfe.log"
echo "Остановить: pkill -9 SeriousSam"
EOF
chmod +x "$RUN"

say "Готово"
cat <<EOF

    Игра:    $GAME
    Запуск:  $RUN
    Выход:   через меню игры; если зависла — pkill -9 SeriousSam

EOF
