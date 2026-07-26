import QtQuick
import QtQuick.Effects

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
        border.color: tile.selected ? "#ff961f" : "transparent"
        gradient: tile.selected ? gradSelected : null

        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        // ── левая группа: иконка + названия ──
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.right: parent.right
            anchors.rightMargin: 170        // место под бейдж и полоски
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Image {
                id: bluetoothIcon
                source: "qrc:/qt/qml/PiDeck/icons/bluetooth.svg"
                sourceSize: Qt.size(64, 64)
                width: 26; height: 26
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                layer.enabled: true
                visible: false
            }
            MultiEffect {
                source: bluetoothIcon
                width: bluetoothIcon.width
                height: bluetoothIcon.height
                anchors.verticalCenter: parent.verticalCenter
                colorization: 1.0
                colorizationColor: tile.connected ? "#ff961f" : "#9094a0"
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
                    color: "#6f7480"
                    font.pixelSize: 14
                    font.family: "monospace"
                }
            }
        }

        // ── правая группа: бейдж + уровень сигнала ──
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
                border.color: "#ff961f"
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: "CONNECTED"
                    color: "#ff961f"
                    font.pixelSize: 11
                    font.letterSpacing: 1
                    font.family: "monospace"
                }
            }

            // полоски сигнала: 4 прямоугольника растущей высоты
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter
                visible: tile.battery > 0        // не все устройства сообщают заряд

                Image {
                    id: battIcon
                    source: tile.battery >= 60 ? "qrc:/qt/qml/PiDeck/icons/batt-full.svg"
                          : tile.battery >= 25 ? "qrc:/qt/qml/PiDeck/icons/batt-midle.svg"
                          :                      "qrc:/qt/qml/PiDeck/icons/batt-low.svg"
                    sourceSize: Qt.size(64, 64)
                    width: 24; height: 24
                    fillMode: Image.PreserveAspectFit
                    anchors.verticalCenter: parent.verticalCenter
                    layer.enabled: true
                    visible: false
                }
                MultiEffect {
                    source: battIcon
                    width: battIcon.width
                    height: battIcon.height
                    anchors.verticalCenter: parent.verticalCenter
                    colorization: 1.0
                    colorizationColor: tile.battery < 20 ? "#ff5c5c"
                                     : tile.connected   ? "#ff961f" : "#9094a0"
                    Behavior on colorizationColor { ColorAnimation { duration: 150 } }
                }

                Text {
                    text: tile.battery + "%"
                    color: tile.battery < 20 ? "#ff5c5c" : "#9094a0"
                    font.pixelSize: 13
                    font.family: "monospace"
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Gradient {
        id: gradSelected
        GradientStop { position: 0.0; color: Qt.rgba(1.0, 150/255, 31/255, 0.18) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}