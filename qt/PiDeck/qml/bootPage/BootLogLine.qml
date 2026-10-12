import QtQuick
import PiDeck

// "[ ✓ ] network: home-5G" — one line of the boot log.
Row {
    id: line

    required property string mark   // "wait", "info", "ok" or "fail"
    required property string text

    readonly property color markColor: mark === "ok"   ? Theme.accent
                                     : mark === "fail" ? Theme.danger
                                                       : Theme.textFaint
    readonly property string glyph: mark === "ok" ? "✓" : mark === "fail" ? "✗" : "•"

    spacing: 10

    Text {
        id: glyphText
        text: "[ " + line.glyph + " ]"
        color: line.markColor
        font.pixelSize: 15
        font.family: "monospace"

        SequentialAnimation on opacity {
            running: line.mark === "wait"
            loops: Animation.Infinite
            NumberAnimation { to: 0.3; duration: 350 }
            NumberAnimation { to: 1;   duration: 350 }
            onStopped: glyphText.opacity = 1
        }
    }

    Text {
        text: line.text
        color: line.mark === "wait" ? Theme.textDim : Theme.textMuted
        font.pixelSize: 15
        font.family: "monospace"
    }
}
