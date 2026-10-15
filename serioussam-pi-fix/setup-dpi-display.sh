#!/usr/bin/env bash
#
# setup-dpi-display.sh — настройка Waveshare RGB LCD HAT + IPS 7" 1024x600 (DPI)
#                        на чистой Raspberry Pi OS (Bookworm / Trixie, KMS).
#
# Проверено: Raspberry Pi 4 и Raspberry Pi 5.
#
# Использование:
#   sudo ./setup-dpi-display.sh                 настроить и перезагрузить
#   sudo ./setup-dpi-display.sh --no-reboot     настроить без перезагрузки
#   sudo ./setup-dpi-display.sh --rotate 180    повернуть изображение (0/90/180/270)
#   sudo ./setup-dpi-display.sh --uninstall     убрать настройки экрана
#
set -euo pipefail

BEGIN="# >>> waveshare-dpi-1024x600 >>>"
END="# <<< waveshare-dpi-1024x600 <<<"
LEGACY="# --- Waveshare 7inch DPI LCD"     # блок от ранних ручных настроек

REBOOT=1; ROTATE=0; UNINSTALL=0
while [ $# -gt 0 ]; do
    case "$1" in
        --no-reboot) REBOOT=0 ;;
        --rotate)    ROTATE="${2:-}"; shift ;;
        --uninstall) UNINSTALL=1 ;;
        -h|--help)   sed -n '2,15p' "$0"; exit 0 ;;
        *) echo "Неизвестный параметр: $1" >&2; exit 1 ;;
    esac
    shift
done
case "$ROTATE" in 0|90|180|270) ;; *) echo "--rotate: допустимо 0, 90, 180, 270" >&2; exit 1 ;; esac

say()  { printf '\n\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] || die "Запустите через sudo: sudo $0 $*"

# --- Где лежит config.txt ----------------------------------------------------
if   [ -f /boot/firmware/config.txt ]; then CFG=/boot/firmware/config.txt
elif [ -f /boot/config.txt ];          then CFG=/boot/config.txt
else die "Не найден config.txt"; fi

MODEL="$(tr -d '\0' < /proc/device-tree/model 2>/dev/null || echo unknown)"
say "Плата: $MODEL"
echo "    конфигурация: $CFG"

# Убрать прежние блоки этого скрипта и ранних ручных настроек
strip_blocks() {
    sed -i "/^$BEGIN\$/,/^$END\$/d" "$CFG"
    sed -i "/^$LEGACY/,\$d" "$CFG"
    sed -i -e :a -e '/^\n*$/{$d;N;ba' -e '}' "$CFG"    # пустые строки в конце файла
}

BAK="$CFG.bak-$(date +%Y%m%d-%H%M%S)"
cp "$CFG" "$BAK"
echo "    резервная копия: $BAK"

# --- Удаление ----------------------------------------------------------------
if [ "$UNINSTALL" -eq 1 ]; then
    say "Удаление настроек экрана"
    strip_blocks
    echo "    блок DPI удалён (UART/I2C/SPI не возвращаются — включите вручную, если нужны)"
    [ "$REBOOT" -eq 1 ] && { say "Перезагрузка"; sleep 3; reboot; }
    exit 0
fi

# --- KMS-драйвер -------------------------------------------------------------
if ! grep -q '^dtoverlay=vc4-kms-v3d' "$CFG"; then
    warn "dtoverlay=vc4-kms-v3d не найден — добавляю (DPI под KMS требует его)"
    sed -i '1i dtoverlay=vc4-kms-v3d' "$CFG"     # начало файла — вне условных секций
fi

# --- Конфликты на GPIO 0-21 ---------------------------------------------------
# DPI занимает GPIO0-21: такт, DE, синхросигналы и 18 линий данных.
say "Освобождение GPIO 0-21 для DPI"
disable_line() {    # $1 — регулярное выражение строки, $2 — пояснение
    if grep -Eq "^$1" "$CFG"; then
        sed -Ei "s|^($1.*)|#\1   # отключено: $2|" "$CFG"
        echo "    отключено: $2"
    fi
}
disable_line 'enable_uart=1'      'UART на GPIO14/15 — линии данных DPI'
disable_line 'dtparam=i2c_arm=on' 'I2C на GPIO2/3 — синхросигналы DPI'
disable_line 'dtparam=spi=on'     'SPI на GPIO7-11 — линии данных DPI'

# Оверлеи, которые могут занимать те же выводы, — только предупреждение
grep -En '^dtoverlay=(w1-gpio|gpio-ir|pwm|spi[0-9]|i2c-gpio|uart[0-9])' "$CFG" 2>/dev/null \
  | while IFS= read -r l; do warn "проверьте, не конфликтует с DPI: $l"; done || true

# --- Блок настроек экрана ----------------------------------------------------
say "Запись настроек экрана"
strip_blocks
# Записываем в конец файла под явной секцией [all]
cat >> "$CFG" <<EOF

$BEGIN
[all]
# Waveshare RGB LCD HAT + IPS 7" 1024x600, DPI 18 бит (RGB666 на GPIO 0-21)
# Тайминги из документации Waveshare: 37 МГц, полный кадр 1240x661,
# синхросигналы инвертированы (в dpi_timings Waveshare поля полярности = 1).
dtoverlay=vc4-kms-dpi-generic
dtparam=hactive=1024,hfp=40,hsync=48,hbp=128
dtparam=vactive=600,vfp=13,vsync=3,vbp=45
dtparam=clock-frequency=37000000
dtparam=hsync-invert
dtparam=vsync-invert
dtparam=width-mm=154,height-mm=86
dtparam=rotate=$ROTATE
$END
EOF
sed -n "/^$BEGIN\$/,/^$END\$/p" "$CFG" | sed 's/^/    /'

# --- Рабочий стол: не гасить DPI при подключённом HDMI ------------------------
# При одновременном HDMI компоновщик может оставить DPI-1 выключенным.
USER_NAME="${SUDO_USER:-$(logname 2>/dev/null || echo '')}"
if [ -n "$USER_NAME" ] && [ "$USER_NAME" != root ]; then
    HOME_DIR="$(getent passwd "$USER_NAME" | cut -d: -f6)"
    LINE='(sleep 3; wlr-randr --output DPI-1 --on) &'
    AS="$HOME_DIR/.config/labwc/autostart"
    sudo -u "$USER_NAME" mkdir -p "$(dirname "$AS")"
    if ! grep -qF 'DPI-1' "$AS" 2>/dev/null; then
        echo "$LINE" | sudo -u "$USER_NAME" tee -a "$AS" >/dev/null
        echo "    автозапуск labwc: $AS"
    fi
    WF="$HOME_DIR/.config/wayfire.ini"
    if [ -f "$WF" ] && ! grep -q 'DPI-1' "$WF"; then
        if grep -q '^\[autostart\]' "$WF"; then
            sed -i '/^\[autostart\]/a dpi_on = sh -c "sleep 3; wlr-randr --output DPI-1 --on"' "$WF"
        else
            printf '\n[autostart]\ndpi_on = sh -c "sleep 3; wlr-randr --output DPI-1 --on"\n' >> "$WF"
        fi
        echo "    автозапуск wayfire: $WF"
    fi
else
    warn "Не удалось определить пользователя рабочего стола — автозапуск DPI-1 не настроен"
fi

# --- Итог --------------------------------------------------------------------
say "Готово"
if grep -q 'Raspberry Pi 5' <<<"$MODEL"; then
    warn "Pi 5: чип RP1 в 18-битном режиме выдаёт 4 бита на канал (аппаратное ограничение),"
    warn "      на плавных градиентах возможны ступеньки. На Pi 4 цвет полный."
fi
cat <<EOF

    Не забудьте включить подсветку переключателем на плате HAT.
    Откат:  sudo $0 --uninstall
    Копия:  $BAK
EOF

if [ "$REBOOT" -eq 1 ]; then
    say "Перезагрузка через 5 секунд (Ctrl+C — отменить)"
    sleep 5
    reboot
else
    echo "    Перезагрузите вручную: sudo reboot"
fi
