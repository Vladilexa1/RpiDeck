import QtQuick
import PiDeck

Item {
    id: tile
    property url img: ""
    property string label: ""
    property bool selected: false
    property bool dimmed: false

    Rectangle {
        anchors.fill: parent
        color: (tile.selected && tile.dimmed) ? Qt.rgba(1, 1, 1, 0.07) : "black"
        border.width: 2
        border.color: tile.selected
                          ? (tile.dimmed ? Qt.rgba(1, 1, 1, 0.08) : Theme.accent)
                          : "transparent"
        radius: 10
        gradient: (tile.selected && !tile.dimmed) ? gradientSelcted : null

        Row {
            spacing: 10
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter

            Icon {
                source: tile.img
                sourceSize: 120
                width: 25; height: 25
                anchors.verticalCenter: parent.verticalCenter
                color: tile.selected ? Theme.accent : Theme.textMuted
                animateColor: true
                colorDuration: 50
            }
            Text {
                text: tile.label
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.pixelSize: 18
            }
        }

        Icon {
            source: "qrc:/qt/qml/PiDeck/icons/right.svg"
            sourceSize: 120
            width: 30; height: 30
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            visible: tile.selected
            color: Theme.textMuted
        }
    }

    Gradient {
        id: gradientSelcted
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
