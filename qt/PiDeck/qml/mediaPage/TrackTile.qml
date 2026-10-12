import QtQuick
import PiDeck

Item {
    id: tile

    implicitHeight: 64

    property string title: ""
    property string album: ""
    property bool   selected: false
    property bool   current: false
    property bool   playing: false

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
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 14

            Text {
                width: 18
                anchors.verticalCenter: parent.verticalCenter
                text: tile.current ? (tile.playing ? "▶" : "❚❚") : "♪"
                color: tile.current ? Theme.accent : Theme.textFaint
                font.pixelSize: tile.current ? 15 : 17
            }

            Column {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 3
                width: parent.width - 32

                Text {
                    text: tile.title
                    color: tile.current ? Theme.accent : "white"
                    font.pixelSize: 18
                    elide: Text.ElideRight
                    width: parent.width
                }
                Text {
                    text: tile.album
                    color: Theme.textDim
                    font.pixelSize: 13
                    font.family: "monospace"
                    elide: Text.ElideRight
                    width: parent.width
                    visible: tile.album !== ""
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
