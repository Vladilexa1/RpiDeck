import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool   interactive: false
    property string actionLabel: ""
    property string toggleLabel: ""

    property var rows: [
        { k: "Shell",      v: "PiDeck v" + SystemInfo.appVersion },
        { k: "Built with", v: SystemInfo.builtWith },
        { k: "OS",         v: SystemInfo.os },
        { k: "Kernel",     v: SystemInfo.kernel },
        { k: "Device",     v: SystemInfo.model + " · " + SystemInfo.memoryTotalGb + " GB" },
        { k: "Serial",     v: SystemInfo.serial }
    ]

    Item {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 44

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "About"
            color: Theme.textBright
            font.pixelSize: 26
            font.bold: true
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: SystemInfo.hostname
            color: Theme.textDim
            font.pixelSize: 14
            font.letterSpacing: 2
            font.family: "monospace"
        }
    }

    Column {
        anchors.top: head.bottom
        anchors.topMargin: 16
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4

        Repeater {
            model: panel.rows

            Item {
                required property var modelData
                required property int index

                width: parent.width
                height: 58

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 1
                    color: Theme.hairline
                    visible: index < panel.rows.length - 1
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.k
                    color: Theme.textMuted
                    font.pixelSize: 17
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.v
                    color: Theme.textBright
                    font.pixelSize: 17
                    font.family: "monospace"
                    elide: Text.ElideMiddle
                    width: Math.min(implicitWidth, panel.width * 0.62)
                    horizontalAlignment: Text.AlignRight
                }
            }
        }
    }
}
