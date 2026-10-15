# OpenMoHAA (Medal of Honor: Allied Assault) на Raspberry Pi

[OpenMoHAA](https://github.com/openmoh/openmohaa) — открытый движок для оригинальной
Medal of Honor: Allied Assault и аддонов Spearhead / Breakthrough.
Проверено: Raspberry Pi 5, Debian 13 (trixie), labwc (Wayland), DPI-экран 1024×600,
русская версия игры, OpenMoHAA 0.82.1.

## Установка

Нужна установленная копия купленной игры (с диска, GOG и т.п.) — достаточно папки `main`
(`Pak*.pk3`, `sound`, `video`). Для аддонов — ещё `mainta` (Spearhead) и `maintt` (Breakthrough).

```bash
~/openmohaa-pi-fix/install.sh "/media/rpi/ФЛЕШКА/mooha/Medal Of Honor Russian Version"
```

Скрипт:
- скачает официальную сборку `openmohaa-v0.82.1-linux-arm64.zip` с GitHub
  в `~/openmohaa-v0.82.1-linux-arm64` (если её там ещё нет);
- выставит файлам права на запуск;
- скопирует `main` (и `mainta`/`maintt`, если есть), пропуская Windows-файлы `.dll`/`.exe`;
- создаст `run-mohaa.sh` с полным экраном в текущем разрешении экрана.

Переменные: `VERSION` (версия движка), `DEST` (папка установки), `SCREEN` (например `SCREEN=1280x720`).
`sudo` не нужен.

## Запуск

```bash
~/openmohaa-v0.82.1-linux-arm64/run-mohaa.sh
```

Аддоны: `run-mohaa.sh spearhead` или `run-mohaa.sh breakthrough`.

**Выход — через меню игры (Esc → Quit).** Если зависла — только `pkill -9 openmohaa`.

## Что нужно знать (грабли, на которые наступили)

1. **Нет прав на запуск.** В официальном zip у файлов нет бита `x` — без `chmod +x`
   ничего не запускается. Скрипт делает это сам.
2. **Движок без данных не работает.** OpenMoHAA — только движок; без `Pak*.pk3` будет
   `Couldn't load default.cfg`. В русской версии набор `Pak0, 1, 2, 5, 7` (без 3, 4, 6) —
   это нормально, русификация лежит в `Pak7.pk3`.
3. **Зависание при SIGTERM.** Если завершить игру обычным `kill`/`pkill`/`timeout`,
   она зависает на выгрузке рендерера внутри видеодрайвера (все потоки в `futex_wait`,
   на экране застывший кадр). Поэтому только выход из меню или `pkill -9`.
4. **Запуск по SSH.** Игра графическая: нужен `DISPLAY=:0`, и её надо отвязать от
   SSH-сессии (`setsid nohup`), иначе она умрёт или зависнет при разрыве соединения.
   `run-mohaa.sh` делает и то, и другое.
5. **Разрешение.** По умолчанию игра открывается в окне. Скрипт запуска передаёт
   `+set r_fullscreen 1 +set r_mode -1 +set r_customwidth/height` — работает с первого
   запуска. Настройки игры хранятся в `~/.openmohaa/main/configs/omconfig.cfg`.
6. **Окно «Abnormal Exit» при запуске.** После `pkill -9` остаётся
   `~/.openmohaa/main/OpenMoHAA.pid`, и игра считает, что прошлый запуск упал.
   `run-mohaa.sh` удаляет этот файл, если игра не запущена.
7. **Лог.** `~/mohaa.log` — сюда пишется вывод игры при запуске через `run-mohaa.sh`.
