import QtQuick

FocusScope {
    id: row

    property string label: ""
    property string valueText: ""       // текст значения справа от заголовка
    default property alias content: body.data   // сюда кладётся контрол

    // строка сама сообщает наверх, что стрелки влево/вправо для неё
    signal decrement()
    signal increment()

    implicitHeight: 64

    Keys.onLeftPressed:  row.decrement()
    Keys.onRightPressed: row.increment()

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: row.activeFocus ? Qt.rgba(1, 1, 1, 0.05) : Qt.rgba(1, 1, 1, 0.02)
        border.width: 2
        border.color: row.activeFocus ? "#ff961f" : "transparent"

        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        // заголовок + значение
        Column {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: row.label
                color: "white"
                font.pixelSize: 18
            }
            Text {
                text: row.valueText
                color: "#6f7480"
                font.pixelSize: 13
                font.family: "monospace"
                visible: row.valueText !== ""
            }
        }

        // тело контрола — прижато вправо
        Item {
            id: body
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            width: 220
            height: parent.height
        }
    }
}