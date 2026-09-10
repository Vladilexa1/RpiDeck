import QtQuick
import QtQuick.Effects

Item {
    id: topPanel
    width: parent.width
    height: 60

    property string tempCPU: "24"
    property string wifiName: "network"
    property string battStatus: "22"
    property string cpuImage: "qrc:/qt/qml/PiDeck/icons/cpu.svg"
    property string wifiImage: "qrc:/qt/qml/PiDeck/icons/wifi-full.svg"
    property string battImage: "qrc:/qt/qml/PiDeck/icons/batt-full.svg"


    Rectangle{
        width: parent.width
        height: parent.height
        gradient: Gradient{
            GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 88)}
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0)}
        }
        Row{
            anchors.fill: parent
            spacing: 10
            anchors.leftMargin: 10
            Text{
                text: new Date().toLocaleString(Qt.locale(""), "hh:mm")
                color: "white"
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 22
            }
            Text{
                text: new Date().toLocaleString(Qt.locale(""), "ddd, MMMM dd")
                color: Theme.textMuted
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 18
            }
        }
        Rectangle{
            width: 12
            height: 12
            radius: 6
            color: Theme.accent
            Text{
                text: "PiDECK"
                anchors.left: parent.right
                anchors.leftMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textMuted
                font.pixelSize: 14
            }
            anchors.centerIn: parent
        }
        Row{
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 25
            anchors.rightMargin: 10
            // CPU
            Row{
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    source: topPanel.cpuImage
                    sourceSize.width: 64
                    sourceSize.height: 64
                    width: 18; height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    text: topPanel.tempCPU + "°C"
                    color: Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                }
            }
            //WIFI
            Row{
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    source: topPanel.wifiImage
                    sourceSize.width: 64
                    sourceSize.height: 64
                    width: 18; height: 18
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    text: topPanel.wifiName
                    color: Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                }
            }
            //Batt
            Row{
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter
                Image{
                    source: topPanel.battImage
                    sourceSize.width: 96
                    sourceSize.height: 64
                    width: 36; height: 24
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    text: topPanel.battStatus + "%"
                    color: Theme.textMuted
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 18
                }
            }
        }
    }
}
