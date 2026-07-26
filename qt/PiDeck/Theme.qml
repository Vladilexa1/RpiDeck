pragma Singleton
import QtQuick

// Единая палитра проекта. Раньше эти цвета были захардкожены в каждом файле.
QtObject {
    readonly property color accent:     "#ff961f"   // оранжевый акцент / выделение
    readonly property color danger:     "#ff5c5c"   // низкий заряд, ошибки
    readonly property color textBright: "#c7cad2"    // светлый текст
    readonly property color textMuted:  "#9094a0"   // основной приглушённый текст
    readonly property color textDim:    "#6f7480"   // подписи, мета
    readonly property color textFaint:  "#5d616d"   // самый тусклый текст
    readonly property color surface:    "#08090c"   // фон панелей

    readonly property color hairline:   Qt.rgba(1, 1, 1, 0.09)  // разделительные линии
    readonly property color tileBg:     Qt.rgba(1, 1, 1, 0.045) // подложка плиток
}
