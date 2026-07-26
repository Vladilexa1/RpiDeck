import QtQuick
import QtQuick.Controls
import QtQuick.Effects
Item{
    id: tile
    property url img: ""
    property string label: ""
    property bool selected: false
    property bool dimmed: false

    Rectangle{
        anchors.fill: parent
        color: (tile.selected && tile.dimmed) ? Qt.rgba(255, 255, 255, 0.07) : "black"
        border.width: 2
        border.color: tile.selected
                          ? (tile.dimmed ? Qt.rgba(1, 1, 1, 0.08) : "#ff961f")
                          : "transparent"
        radius: 10
        gradient: (tile.selected && !tile.dimmed) ? gradientSelcted : null
        Row{
            spacing: 10
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            Image{
                id: icon2
                source: tile.img
                sourceSize.width: 120
                sourceSize.height: 120
                width: 25
                height: 25
                fillMode: Image.PreserveAspectFit
                anchors.verticalCenter: parent.verticalCenter
                layer.enabled: true
                visible: false
            }
            MultiEffect {
                source: icon2
                width: icon2.width
                height: icon2.height
                anchors.verticalCenter: parent.verticalCenter
                colorization: 1.0
                colorizationColor: tile.selected ? "#ff961f" : "#9094a0"
                Behavior on colorizationColor { ColorAnimation { duration: 50 } }
            }
            Text{
                text: tile.label
                anchors.verticalCenter: parent.verticalCenter
                color: "white"
                font.pixelSize: 18
            }
        }
        Image{
            id: icon3
            source: "qrc:/qt/qml/PiDeck/icons/right.svg"
            sourceSize.width: 120
            sourceSize.height: 120
            anchors.right: parent.right
            anchors.rightMargin: 5
            width: 30
            height: 30
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            layer.enabled: true
            visible: false
        }
        MultiEffect {
            source: icon3
            width: icon3.width
            height: icon3.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 5
            colorization: 1.0
            visible: tile.selected
            colorizationColor: "#9094a0"
            Behavior on colorizationColor { ColorAnimation { duration: 50 } }
        }
    }
    Gradient{
        id: gradientSelcted
                GradientStop{ position: 0.0; color: Qt.rgba(255/255, 150/255, 31/255, 0.3) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0)}
    }
}