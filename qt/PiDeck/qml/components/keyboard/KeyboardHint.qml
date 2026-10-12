pragma ComponentBehavior: Bound
import QtQuick
import PiDeck

// "[Start] / [Enter]  done" — the gamepad control first, the keyboard one second.
Row {
    id: hint

    property var    keys: []
    property string label: ""

    spacing: 6

    Repeater {
        model: hint.keys

        Row {
            id: chip
            required property string modelData
            required property int index

            spacing: 6

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "/"
                color: Theme.textFaint
                font.pixelSize: 13
                visible: chip.index > 0
            }
            NavigationIcon {
                anchors.verticalCenter: parent.verticalCenter
                label: chip.modelData
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: hint.label
        color: Theme.textMuted
        font.pixelSize: 14
    }
}
