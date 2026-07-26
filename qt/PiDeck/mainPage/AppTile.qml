import QtQuick

Item {
    id: tile
    property string label: ""
    property bool selected: false
    property url img: ""
    property color colorGlow: "transparent"
    property string category: ""

    Rectangle {
        width: parent.width
        height: 125
        radius: 25
        color: Theme.tileBg
        gradient: tile.selected ? gradientSelcted : null

        anchors.bottom: parent.bottom
        anchors.bottomMargin: tile.selected ? 25 : 15

        border.width: tile.selected ? 4 : 3
        border.color: tile.selected ? Theme.accent : Theme.textMuted

        Icon {
            source: tile.img
            sourceSize: 120
            width: 45
            height: 45
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -15
            color: tile.selected ? Theme.accent : Theme.textMuted
            animateColor: true
        }

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
