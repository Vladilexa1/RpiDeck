import QtQuick
import PiDeck

FocusScope {
    id: panel
    signal exitLeft()

    property bool   interactive: false
    property string actionLabel: ""
    property string toggleLabel: ""

    property string shell:     "EMBER v0.3"
    property string builtWith: "Qt 6.6 · QML"
    property string os:        "Ember OS · Debian 12"
    property string kernel:    "Linux 6.6 aarch64"
    property string serial:    "10000000a1b2c3d4"

    property var rows: [
        { k: "Shell",      v: panel.shell },
        { k: "Built with", v: panel.builtWith },
        { k: "OS",         v: panel.os },
        { k: "Kernel",     v: panel.kernel },
        { k: "Serial",     v: panel.serial }
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
            text: "EMBER OS"
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
                }
            }
        }
    }
}