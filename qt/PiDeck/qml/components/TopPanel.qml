import QtQuick
import PiDeck

Item {
    id: topPanel

    height: 60

    // часы: без таймера биндинг с new Date() вычисляется один раз и встаёт
    property var now: new Date()

    readonly property string cpuText: SystemMonitor.cpuTemp >= 0
                                      ? SystemMonitor.cpuTemp + "°C"
                                      : "--"

    readonly property string wifiText: WifiController.radioEnabled
                                       ? (WifiController.connected ? WifiController.connectedSsid
                                                                   : "not connected")
                                       : "off"

    readonly property string wifiImage: {
        if (!WifiController.radioEnabled || !WifiController.connected)
            return "qrc:/qt/qml/PiDeck/assets/icons/wifi-zero.svg"
        if (WifiController.connectedLevel >= 66)
            return "qrc:/qt/qml/PiDeck/assets/icons/wifi-full.svg"
        if (WifiController.connectedLevel >= 33)
            return "qrc:/qt/qml/PiDeck/assets/icons/wifi-midle.svg"
        return "qrc:/qt/qml/PiDeck/assets/icons/wifi-low.svg"
    }

    readonly property string battImage: {
        if (SystemMonitor.charging)
            return "qrc:/qt/qml/PiDeck/assets/icons/batt-charg.svg"
        if (SystemMonitor.batteryLevel >= 66)
            return "qrc:/qt/qml/PiDeck/assets/icons/batt-full.svg"
        if (SystemMonitor.batteryLevel >= 33)
            return "qrc:/qt/qml/PiDeck/assets/icons/batt-midle.svg"
        if (SystemMonitor.batteryLevel >= 10)
            return "qrc:/qt/qml/PiDeck/assets/icons/batt-low.svg"
        return "qrc:/qt/qml/PiDeck/assets/icons/batt-zero.svg"
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: topPanel.now = new Date()
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0.88) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 10
            spacing: 10

            Text {
                text: topPanel.now.toLocaleString(Qt.locale(""), "hh:mm")
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
            }
            Text {
                text: topPanel.now.toLocaleString(Qt.locale(""), "ddd, MMMM dd")
                color: Theme.textMuted
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
            }
        }

        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Theme.accent
            anchors.centerIn: parent

            Text {
                text: "PiDECK"
                anchors.left: parent.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textMuted
                font.pixelSize: 14
            }
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            spacing: 25

            // CPU
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    source: "qrc:/qt/qml/PiDeck/assets/icons/cpu.svg"
                    sourceSize.width: 64
                    sourceSize.height: 64
                    width: 18; height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: topPanel.cpuText
                    color: SystemMonitor.cpuTemp >= 75 ? Theme.danger : Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                }
            }

            // Wi-Fi
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    source: topPanel.wifiImage
                    sourceSize.width: 64
                    sourceSize.height: 64
                    width: 18; height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: topPanel.wifiText
                    color: Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: Math.min(implicitWidth, 160)
                }
            }

            // батарея: на Pi без UPS её нет, тогда блок просто не показываем
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                visible: SystemMonitor.batteryPresent

                Image {
                    source: topPanel.battImage
                    sourceSize.width: 96
                    sourceSize.height: 64
                    width: 36; height: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: SystemMonitor.batteryLevel + "%"
                    color: SystemMonitor.batteryLevel <= 15 && !SystemMonitor.charging
                           ? Theme.danger : Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                }
            }
        }
    }
}
