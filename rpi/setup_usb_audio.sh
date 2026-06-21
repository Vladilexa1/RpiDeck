#!/bin/bash
# Находит USB-аудиокарту, ставит её дефолтной в ALSA и проигрывает тест.
# Запуск:  ./setup_usb_audio.sh

set -e

# 1. Найти строку с USB-картой в aplay -l
LINE=$(aplay -l 2>/dev/null | grep -i "card.*USB" | head -1)

if [ -z "$LINE" ]; then
    echo "❌ USB-аудио не найдено."
    echo "   Проверь подключение и вывод 'aplay -l'."
    exit 1
fi

# 2. Вытащить номер и короткое имя карты
#    Формат строки: "card 2: Device [USB Audio Device], device 0: ..."
CARD_NUM=$(echo "$LINE" | sed -E 's/^card ([0-9]+):.*/\1/')
CARD_NAME=$(echo "$LINE" | sed -E 's/^card [0-9]+: ([^ ]+) \[.*/\1/')

echo "✓ Найдена USB-карта: №$CARD_NUM, имя \"$CARD_NAME\""

# 3. Прописать в ~/.asoundrc по имени (не по номеру — номер может меняться)
cat > ~/.asoundrc << EOF
defaults.pcm.card "$CARD_NAME"
defaults.ctl.card "$CARD_NAME"
EOF
echo "✓ Записан ~/.asoundrc"

# 4. Поднять громкость и снять mute (микшер может называться по-разному)
for CTL in 'PCM' 'Speaker' 'Master' 'Headphone'; do
    if amixer -c "$CARD_NUM" sget "$CTL" >/dev/null 2>&1; then
        amixer -c "$CARD_NUM" sset "$CTL" 80% unmute >/dev/null 2>&1 && \
            echo "✓ $CTL: 80%, unmute"
    fi
done

# 5. Тест
echo ""
echo "▶ Тест: должно прозвучать 'Front Left' и 'Front Right'..."
sleep 1
speaker-test -D plughw:"$CARD_NUM",0 -c 2 -t wav -l 1

echo ""
echo "✓ Готово. Если звук есть — теперь aplay/mpv/speaker-test играют автоматически на USB."