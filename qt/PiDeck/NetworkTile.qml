import QtQuick

Item {
    id: tile

    property string ssid: ""
    property bool   secured: false
    property int    level: 0
    property bool   connected: false
    property string security: ""
    property string ip: ""
    property bool   selected: false

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: tile.selected ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.02)
        border.width: 2
        border.color: tile.selected ? Theme.accent : "transparent"
        gradient: tile.selected ? gradSelected : null

        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 170
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Icon {
                source: "qrc:/qt/qml/PiDeck/icons/wifi-full.svg"
                width: 26; height: 26
                anchors.verticalCenter: parent.verticalCenter
                color: tile.connected ? Theme.accent : Theme.textMuted
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3

                Row {
                    spacing: 8
                    Text {
                        text: tile.ssid
                        color: "white"
                        font.pixelSize: 19
                    }
                    Image {
                        source: "qrc:/qt/qml/PiDeck/icons/lock.svg"
                        sourceSize: Qt.size(32, 32)
                        width: 13; height: 13
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.55
                        visible: tile.secured
                    }
                }

                Text {
                    text: tile.connected ? "connected · " + tile.ip
                                         : (tile.secured ? tile.security : "open")
                    color: Theme.textDim
                    font.pixelSize: 14
                    font.family: "monospace"
                }
            }
        }
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Rectangle {
                visible: tile.connected
                width: badgeText.implicitWidth + 20
                height: 26
                radius: 6
                color: "transparent"
                border.width: 1
                border.color: Theme.accent
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: "CONNECTED"
                    color: Theme.accent
                    font.pixelSize: 11
                    font.letterSpacing: 1
                    font.family: "monospace"
                }
            }
            Row {
                spacing: 3
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: 4
                    Rectangle {
                        width: 4
                        height: 7 + index * 4
                        radius: 1
                        anchors.bottom: parent.bottom
                        color: tile.level >= (index + 1) * 22
                               ? Theme.accent : Qt.rgba(1, 1, 1, 0.13)
                    }
                }
            }
        }
    }

    Gradient {
        id: gradSelected
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
