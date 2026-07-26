import QtQuick
import QtQuick.Effects

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
                id: wifiIcon
                source: "qrc:/qt/qml/PiDeck/icons/wifi-full.svg"
                sourceSize: Qt.size(64, 64)
                width: 26; height: 26
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                layer.enabled: true
                visible: false
            }
            MultiEffect {
                source: wifiIcon
                width: wifiIcon.width
                height: wifiIcon.height
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
                        opacity: 0.55           // белый SVG + прозрачность = серый
                        visible: tile.secured
                    }
                }

                Text {
                    text: tile.connected ? "connected · " + tile.ip
                                         : (tile.secured ? tile.security : "open")
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
                spacing: 3
                height: 20
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: 4
                    Rectangle {
                        width: 4
                        height: 7 + index * 4
                        radius: 1
                        anchors.bottom: parent.bottom       // вертикальные анкоры в Row можно
                        color: tile.level >= (index + 1) * 22
                               ? "#ff961f" : Qt.rgba(1, 1, 1, 0.13)
                    }
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