import QtQuick

Item {
    id: ctl

    property int value: 50
    property int from: 0
    property int to: 100

    anchors.verticalCenter: parent.verticalCenter
    width: 220
    height: 24

    // дорожка
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.10)

        // заполнение
        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: parent.height
            radius: 3
            width: parent.width * (ctl.value - ctl.from) / (ctl.to - ctl.from)
            color: "#ff961f"
            Behavior on width { NumberAnimation { duration: 100 } }
        }
    }

    // ползунок
    Rectangle {
        width: 16; height: 16
        radius: 8
        color: "#ff961f"
        anchors.verticalCenter: parent.verticalCenter
        x: (track.width - width) * (ctl.value - ctl.from) / (ctl.to - ctl.from)
        Behavior on x { NumberAnimation { duration: 100 } }
    }
}