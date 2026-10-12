import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool   interactive: true
    property string actionLabel: ""
    property string toggleLabel: ""
    property int brightness: 70
    property int uiScale: 100

    property int currentRow: 0
    readonly property int rowCount: 2

    focus: true

    Keys.onLeftPressed: panel.exitLeft()
    Keys.onEscapePressed: panel.exitLeft()

    Keys.onUpPressed:   if (currentRow > 0) currentRow--
    Keys.onDownPressed: if (currentRow < rowCount - 1) currentRow++

    Text {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        text: "Display"
        color: "white"
        font.pixelSize: 26
        font.bold: true
    }

    Column {
        anchors.top: head.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10

        SettingRow {
            width: parent.width
            label: "Brightness"
            valueText: panel.brightness + "%"
            focus: panel.currentRow === 0

            onDecrement: panel.brightness = Math.max(0, panel.brightness - 5)
            onIncrement: panel.brightness = Math.min(100, panel.brightness + 5)

            SettingsSlider {
                value: panel.brightness
                from: 0; to: 100
            }
        }

        SettingRow {
            width: parent.width
            label: "UI Scale"
            valueText: panel.uiScale + "%"
            focus: panel.currentRow === 1

            onDecrement: panel.uiScale = Math.max(75,  panel.uiScale - 25)
            onIncrement: panel.uiScale = Math.min(150, panel.uiScale + 25)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                spacing: 14

                Text { text: "‹"; color: "#9094a0"; font.pixelSize: 22 }
                Text {
                    text: panel.uiScale + "%"
                    color: "#ff961f"
                    font.pixelSize: 18
                    font.family: "monospace"
                    width: 60
                    horizontalAlignment: Text.AlignHCenter
                }
                Text { text: "›"; color: "#9094a0"; font.pixelSize: 22 }
            }
        }
    }
}