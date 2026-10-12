pragma ComponentBehavior: Bound
import QtQuick
import PiDeck

// One petal of the radial keyboard: four keys laid out like the face buttons.
Rectangle {
    id: tile

    property var  labels: ["", "", "", ""]   // Y, B, A, X
    property bool selected: false

    readonly property var buttonNames:  ["Y", "B", "A", "X"]
    readonly property var buttonColors: ["#f5c542", "#ff5c5c", "#4cd964", "#4a9eff"]
    readonly property var offsets: [Qt.point(0, -1), Qt.point(1, 0), Qt.point(0, 1), Qt.point(-1, 0)]

    radius: width * 0.18
    color: selected ? Theme.surface : Theme.tileBg
    border.width: selected ? 2 : 1
    border.color: selected ? Theme.accent : Theme.hairline
    scale: selected ? 1.22 : 1
    z: selected ? 1 : 0

    Behavior on scale        { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    Behavior on border.color { ColorAnimation  { duration: 120 } }

    Repeater {
        model: 4

        Item {
            id: key
            required property int index

            width: tile.width * 0.3
            height: width
            x: (tile.width - width) / 2 + tile.offsets[index].x * tile.width * 0.29
            y: (tile.height - height) / 2 + tile.offsets[index].y * tile.height * 0.29

            Rectangle {
                anchors.fill: parent
                radius: 6
                color: "transparent"
                border.width: 1.5
                border.color: tile.buttonColors[key.index]
                visible: tile.selected && tile.labels[key.index] !== ""
            }

            Text {
                anchors.centerIn: parent
                text: tile.labels[key.index]
                color: tile.selected ? "white" : Theme.textMuted
                font.pixelSize: tile.width * (tile.selected ? 0.22 : 0.2)
            }

            Rectangle {
                width: 13
                height: 13
                radius: 6.5
                x: parent.width - width / 2 - 2
                y: parent.height - height / 2 - 2
                color: tile.buttonColors[key.index]
                visible: tile.selected && tile.labels[key.index] !== ""

                Text {
                    anchors.centerIn: parent
                    text: tile.buttonNames[key.index]
                    color: "black"
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }
    }
}
