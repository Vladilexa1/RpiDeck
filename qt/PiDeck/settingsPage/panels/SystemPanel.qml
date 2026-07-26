import QtQuick
import PiDeck

FocusScope {
    id: panel
    signal exitLeft()

    property bool   interactive: false
    property string actionLabel: ""
    property string toggleLabel: ""
    property string hostname:  "ember"
    property string model:     "Raspberry Pi 5 · 8 GB"
    property int    cpuTemp:   48
    property string uptime:    "3h 12m"
    property int    storageUsed: 34
    property int    storageTotal: 64

    readonly property bool healthy: cpuTemp < 75 && storageUsed < 90
    readonly property color tempColor: cpuTemp >= 75 ? Theme.danger
                                      : cpuTemp >= 60 ? Theme.accent
                                      :                 Theme.textBright

    property var rows: [
        { k: "Hostname",        v: panel.hostname,             c: Theme.textBright },
        { k: "Model",           v: panel.model,                c: Theme.textBright },
        { k: "CPU temperature", v: panel.cpuTemp + " °C",      c: panel.tempColor },
        { k: "Uptime",          v: panel.uptime,               c: Theme.textBright }
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
            text: "System"
            color: Theme.textBright
            font.pixelSize: 26
            font.bold: true
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: panel.healthy ? "healthy" : "warning"
            color: panel.healthy ? Theme.textDim : Theme.danger
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

        // текстовые
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
                    color: modelData.c
                    font.pixelSize: 17
                    font.family: "monospace"
                }
            }
        }
        Item {
            width: parent.width
            height: 58

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                text: "Storage"
                color: Theme.textMuted
                font.pixelSize: 17
            }

            Row {
                anchors.right: parent.right
                anchors.rightMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Text {
                    text: Math.round(panel.storageUsed * panel.storageTotal / 100)
                          + " / " + panel.storageTotal + " GB"
                    color: Theme.textDim
                    font.pixelSize: 14
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 160
                    height: 8
                    radius: 4
                    color: Theme.hairline
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        height: parent.height
                        radius: 4
                        width: parent.width * Math.max(0, Math.min(100, panel.storageUsed)) / 100
                        color: panel.storageUsed >= 90 ? Theme.danger : Theme.accent
                        Behavior on width { NumberAnimation { duration: 300 } }
                    }
                }
            }
        }
    }
}