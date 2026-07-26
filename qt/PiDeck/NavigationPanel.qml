import QtQuick

Item {
    id: bottomLine
    height: 50

    // страница задаёт свой набор подсказок
    property var actions: []

    Rectangle {
        anchors.fill: parent
        color: Theme.surface

        Rectangle {
            width: parent.width
            height: 1
            color: Theme.hairline
        }

        Row {
            anchors.fill: parent
            anchors.leftMargin: 20
            spacing: 10

            Repeater {
                model: bottomLine.actions
                NavTile {
                    label: modelData.label
                    icon: modelData.icon
                    visible: modelData.label !== ""
                }
            }
        }

        Text {
            text: "PiDECK  ·  V0.3"
            color: Theme.textFaint
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}