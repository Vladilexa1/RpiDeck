import QtQuick

Item {
    id: tile
    property string label: ""
    property bool selected: false
    property url img: ""
    property color colorGlow: "transparent"
    property string category: ""

    Rectangle {
        width: gamePanel.width / 6 - 20
        height: tile.selected ? gamePanel.height / 2 - 30 + 5 : gamePanel.height / 2 - 30
        radius: 10
        color: "transparent"
        anchors.bottom: parent.bottom
        border.width: 2
        border.color: tile.selected ? Theme.accent : Theme.textMuted
        Text {
            text: label
            color: tile.selected ? "white" : Theme.textMuted
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            font.pixelSize: 20
        }
    }

    Gradient {
        id: gradientSelcted
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
