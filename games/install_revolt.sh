#!/usr/bin/env bash
#===============================================================================
# install-rvgl.sh - установка RVGL (Re-Volt) на Debian / Raspberry Pi OS
#
#   Использование:
#       ./install-rvgl.sh [каталог]            # по умолчанию ~/games/rvgl
#       ./install-rvgl.sh ~/games/rvgl --run   # установить и сразу запустить
#
#   Переменные окружения:
#       RVGL_ZIP=/путь/к/rvgl_full_linux_original.zip   использовать свой архив
#
#   ВНИМАНИЕ. В комплекте RVGL есть скрипты setup и fix_cases. Они РЕКУРСИВНО
#   приводят имена всех файлов в своём каталоге к нижнему регистру. Запущенные
#   не в той папке, они перепишут имена в домашнем каталоге. Этот установщик
#   их НЕ вызывает и делает нужное сам.
#===============================================================================
set -euo pipefail

ZIP_URL="https://distribute.re-volt.io/releases/rvgl_full_linux_original.zip"
PKGS=(libsdl2-2.0-0 libsdl2-image-2.0-0 libopenal1 zenity unzip wget ca-certificates)

RVGL_DIR=""; DO_RUN=0
for a in "$@"; do
  case "$a" in
    --run) DO_RUN=1 ;;
    -h|--help) sed -n '2,18p' "$0"; exit 0 ;;
    *) RVGL_DIR="$a" ;;
  esac
done
RVGL_DIR="$(realpath -m "${RVGL_DIR:-$HOME/games/rvgl}")"

CACHE_DIR="$HOME/.cache/rvgl"
ZIP="${RVGL_ZIP:-$CACHE_DIR/rvgl_full_linux_original.zip}"

say()  { printf '\n\033[1;32m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

#--- 0. Защита от установки не туда --------------------------------------------
case "$RVGL_DIR" in
  "$HOME"|/|/home|/root|/usr|/etc|/var) die "Нельзя ставить прямо в $RVGL_DIR. Укажите отдельный подкаталог." ;;
esac
if [ -e "$RVGL_DIR" ] && [ -n "$(ls -A "$RVGL_DIR" 2>/dev/null)" ]; then
  [ -f "$RVGL_DIR/rvgl" ] || die "Каталог $RVGL_DIR не пуст и не похож на RVGL. Выберите другой."
  warn "Каталог $RVGL_DIR уже содержит RVGL, файлы будут перезаписаны."
fi

#--- 1. Архитектура ------------------------------------------------------------
case "$(uname -m)" in
  aarch64)        SUFFIX=arm64 ;;
  armv7l|armv6l)  SUFFIX=armhf ;;
  x86_64)         SUFFIX=64 ;;
  i?86)           SUFFIX=32 ;;
  *) die "Неизвестная архитектура: $(uname -m)" ;;
esac
say "Архитектура $(uname -m), будет использован rvgl.$SUFFIX"

#--- 2. Зависимости ------------------------------------------------------------
say "Проверка зависимостей"
MISSING=()
for p in "${PKGS[@]}"; do
  dpkg-query -W -f='${Status}' "$p" 2>/dev/null | grep -q "ok installed" || MISSING+=("$p")
done
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "Не хватает: ${MISSING[*]}"
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends "${MISSING[@]}"
else
  echo "Всё на месте: ${PKGS[*]}"
fi

#--- 3. Загрузка ---------------------------------------------------------------
say "Игровой пакет (движок + данные, ~184 МБ)"
if [ -f "$ZIP" ] && unzip -tqq "$ZIP" >/dev/null 2>&1; then
  echo "Использую готовый архив: $ZIP"
else
  mkdir -p "$(dirname "$ZIP")"
  echo "Качаю $ZIP_URL"
  wget -c -O "$ZIP" "$ZIP_URL" || die "Загрузка не удалась."
  echo "Проверяю целостность архива"
  unzip -tqq "$ZIP" >/dev/null 2>&1 || die "Архив повреждён, удалите $ZIP и повторите."
fi

#--- 4. Распаковка -------------------------------------------------------------
say "Распаковка в $RVGL_DIR"
mkdir -p "$RVGL_DIR"
unzip -q -o "$ZIP" -d "$RVGL_DIR"
# если внутри архива оказался один вложенный каталог, поднимаем содержимое наверх
if [ ! -f "$RVGL_DIR/rvgl" ]; then
  inner="$(find "$RVGL_DIR" -mindepth 2 -maxdepth 2 -name rvgl -type f -print -quit || true)"
  [ -n "$inner" ] || die "В архиве не найден лаунчер rvgl."
  inner="$(dirname "$inner")"
  (shopt -s dotglob; mv "$inner"/* "$RVGL_DIR"/) && rmdir "$inner"
fi
[ -f "$RVGL_DIR/models/go2.m" ] || die "Игровые данные неполные: нет models/go2.m."

#--- 5. Библиотеки: относительные симлинки, чтобы папку можно было переносить ---
say "Настройка библиотек"
cd "$RVGL_DIR/lib"
rm -f ./*.so*                       # чистим возможные абсолютные ссылки
for f in libenet.so.7 libopenal.so.1 libunistring.so.2; do
  if [ -e "lib$SUFFIX/$f" ]; then ln -sfn "lib$SUFFIX/$f" "$f"; echo "  $f -> lib$SUFFIX/$f"; fi
done
cd "$RVGL_DIR"

#--- 6. Пак-лист и права -------------------------------------------------------
say "Конфигурация"
mkdir -p packs/local profiles cache replays times
[ -f packs/default.txt ] || printf 'default\nlocal *\n' > packs/default.txt
chmod ugo+x rvgl rvgl.32 rvgl.64 rvgl.armhf rvgl.arm64 setup fix_cases alsoft_log 2>/dev/null || true
chmod -R ugo+rw cache profiles replays times packs/local 2>/dev/null || true
echo "  packs/default.txt, права на запись в profiles/cache/replays/times"

#--- 7. Ярлык в меню -----------------------------------------------------------
say "Ярлык в меню приложений"
APPS="$HOME/.local/share/applications"; mkdir -p "$APPS"
cat > "$APPS/RVGL.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=RVGL
Comment=Re-Volt (RVGL)
Categories=Game;ArcadeGame;
Terminal=false
Path=$RVGL_DIR
Exec=$RVGL_DIR/rvgl
Icon=$RVGL_DIR/icons/256x256/apps/rvgl.png
DESKTOP
chmod +x "$APPS/RVGL.desktop"
update-desktop-database "$APPS" >/dev/null 2>&1 || true
echo "  $APPS/RVGL.desktop"

#--- 8. Проверка ---------------------------------------------------------------
say "Проверка установки"
export LD_LIBRARY_PATH="$RVGL_DIR/lib:${LD_LIBRARY_PATH:-}"
if ldd "./rvgl.$SUFFIX" | grep -q "not found"; then
  ldd "./rvgl.$SUFFIX" | grep "not found"
  die "Остались неразрешённые библиотеки."
fi
printf '  машин: %s | трасс: %s | звуков: %s | музыки: %s\n' \
  "$(ls cars | wc -l)" "$(ls levels | wc -l)" "$(ls wavs | wc -l)" "$(ls redbook | wc -l)"
echo "  все библиотеки разрешены"

say "Готово. Установлено в $RVGL_DIR"
cat <<INFO

  Запуск:   cd "$RVGL_DIR" && ./rvgl
  Или через меню приложений, пункт RVGL.

  Запускать надо на экране самого устройства. По SSH без DISPLAY игра не стартует.

  Сообщения "Error loading libFLAC.so.12" и строки "GL_...: Not Found" в логе
  безвредны. Первое - необязательный кодек, второе - обычный опрос расширений
  OpenGL. Лог игры лежит в profiles/rvgl.log.

  НЕ запускайте ./setup и ./fix_cases из домашней папки. Они рекурсивно
  переименовывают всё вокруг в нижний регистр. Внутри $RVGL_DIR они безопасны
  и нужны, только если вы добавляете пользовательские трассы и машины.

INFO

if [ "$DO_RUN" = 1 ]; then
  if [ -z "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    warn "Нет DISPLAY/WAYLAND_DISPLAY, запуск пропущен."
  else
    say "Запуск"
    cd "$RVGL_DIR" && exec ./rvgl
  fi
fi
