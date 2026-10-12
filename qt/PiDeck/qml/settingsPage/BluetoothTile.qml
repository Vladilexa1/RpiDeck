import QtQuick

Item {
    id: tile

    property string name: ""
    property string type: ""
    property int    battery: 0
    property bool   paired: false
    property bool   connected: false
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
                source: "qrc:/qt/qml/PiDeck/assets/icons/bluetooth.svg"
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
                        text: tile.name
                        color: "white"
                        font.pixelSize: 19
                    }
                }

                Text {
                    text: tile.connected ? "connected" : ""
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
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                visible: tile.battery > 0

                Icon {
                    source: tile.battery >= 60 ? "qrc:/qt/qml/PiDeck/assets/icons/batt-full.svg"
                          : tile.battery >= 25 ? "qrc:/qt/qml/PiDeck/assets/icons/batt-midle.svg"
                          :                      "qrc:/qt/qml/PiDeck/assets/icons/batt-low.svg"
                    width: 24; height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    color: tile.battery < 20 ? Theme.danger
                         : tile.connected   ? Theme.accent : Theme.textMuted
                    animateColor: true
                }

                Text {
                    text: tile.battery + "%"
                    color: tile.battery < 20 ? Theme.danger : Theme.textMuted
                    font.pixelSize: 13
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter
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
