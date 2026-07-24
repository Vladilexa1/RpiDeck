import QtQuick
import QtQuick.Effects

Item {
    id: tile
    property string label: ""
    property bool selected: false
    property Component imgComponent: null
    property url img: ""
    property color colorGlow: "transparent"
    property string category: ""

    Rectangle{
        width: parent.width
        height: 125
        radius: 25
        color: Qt.rgba(255, 255, 255, 0.045)
        gradient: tile.selected ? gradientSelcted : null

        anchors.bottom: parent.bottom
        anchors.bottomMargin: tile.selected ? 25 : 15

        Image{
            id: icon
            source: tile.img
            sourceSize.width: 120
            sourceSize.height: 120
            width: 45
            height: 45
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -15
            visible: false
            layer.enabled: true
        }
        MultiEffect {
            source: icon
            anchors.fill: icon
            colorization: 1.0
            colorizationColor: tile.selected ? "#ff961f" : "#9094a0"
            Behavior on colorizationColor { ColorAnimation { duration: 150 } }
        }

        border.width: tile.selected ? 4 : 3
        border.color: tile.selected ? "#ff961f" : "#9094a0"
        Text{
            text: label
            color: tile.selected ? "white" : "#9094a0"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            font.pixelSize: 20
        }
    }
    Gradient{
        id: gradientSelcted
                GradientStop{ position: 0.0; color: Qt.rgba(255/255, 150/255, 31/255, 0.3) }
                GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0)}
    }
}
