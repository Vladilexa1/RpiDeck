import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool   interactive: false
    property string actionLabel: ""
    property string toggleLabel: ""

    readonly property string cpuText: SystemMonitor.cpuTemp >= 0
                                      ? SystemMonitor.cpuTemp + " °C"
                                      : "--"

    readonly property bool healthy: SystemMonitor.cpuTemp < 75
                                    && SystemInfo.storageUsedPercent < 90

    readonly property color tempColor: SystemMonitor.cpuTemp >= 75 ? Theme.danger
                                     : SystemMonitor.cpuTemp >= 60 ? Theme.accent
                                     :                               Theme.textBright

    property var rows: [
        { k: "Hostname",        v: SystemInfo.hostname,                 c: Theme.textBright },
        { k: "Model",           v: SystemInfo.model,                    c: Theme.textBright },
        { k: "CPU temperature", v: panel.cpuText,                       c: panel.tempColor },
        { k: "CPU load",        v: SystemMonitor.cpuLoad >= 0
                                   ? SystemMonitor.cpuLoad + " %" : "--", c: Theme.textBright },
        { k: "Uptime",          v: SystemInfo.uptime,                   c: Theme.textBright }
    ]

    component UsageRow: Item {
        id: usage

        property string label: ""
        property string valueText: ""
        property int percent: 0

        height: 58

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            text: usage.label
            color: Theme.textMuted
            font.pixelSize: 17
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 4
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12

            Text {
                text: usage.valueText
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
                    width: parent.width * Math.max(0, Math.min(100, usage.percent)) / 100
                    color: usage.percent >= 90 ? Theme.danger : Theme.accent
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }
        }
    }

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

        Repeater {
            model: panel.rows

            Item {
                required property var modelData
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
                    elide: Text.ElideMiddle
                    width: Math.min(implicitWidth, panel.width * 0.6)
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        UsageRow {
            width: parent.width
            label: "Memory"
            valueText: SystemInfo.memoryUsedGb + " / " + SystemInfo.memoryTotalGb + " GB"
            percent: SystemInfo.memoryUsedPercent
        }

        UsageRow {
            width: parent.width
            label: "Storage"
            valueText: SystemInfo.storageUsedGb + " / " + SystemInfo.storageTotalGb + " GB"
            percent: SystemInfo.storageUsedPercent
        }
    }
}
