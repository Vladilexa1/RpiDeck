import QtQuick
import QtQuick.Effects

Item {
    id: tile
    property string label: ""
    property bool selected: false
    property url img: ""
    property string category: ""
    property string description: ""

    Rectangle {
        id: card
        width: gamePanel.width / 6 - 20
        height: tile.selected ? gamePanel.height / 2 - 30 + 5 : gamePanel.height / 2 - 30
        radius: 10
        color: "transparent"
        anchors.bottom: parent.bottom
        border.width: 3
        border.color: tile.selected ? Theme.accent : Theme.textMuted
        clip: true
        Item {
            id: imgSource
            anchors.fill: parent
            anchors.margins: 2
            visible: false
            layer.enabled: true

            Image {
                anchors.fill: parent
                source: tile.img
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: width
                sourceSize.height: height
            }
        }
        Rectangle {
            id: mask
            anchors.fill: imgSource
            radius: card.radius - 2
            visible: false
            layer.enabled: true
        }

        MultiEffect {
            anchors.fill: imgSource
            source: imgSource
            maskEnabled: true
            maskSource: mask
        }
    }

    Gradient {
        id: gradientSelcted
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
