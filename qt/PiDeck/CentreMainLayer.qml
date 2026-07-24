import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import QtQuick.Shapes

Rectangle {
    id: center
    property var tile: null

    property string category:         tile ? tile.category  : ""
    property string label:            tile ? tile.label     : ""
    property string sourceImage:      tile ? tile.img       : ""
    property string shortDescription: tile ? tile.shortDescription : ""
    property string subtitle:         tile ? tile.subtitle     : ""
    property string description:      tile ? tile.description : ""
    property color  colorGlow:        tile ? tile.colorGlow : Qt.rgba(0, 0, 0, 0)

    width: parent.width
    height: parent.height - topPanel.height - 100
    color: "black"

    Rectangle {
        id: left
        width: parent.width / 2
        height: parent.height
        color: "black"
        anchors.left: parent.left
        Column{
            anchors.left: parent.left
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.leftMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 20
            spacing: 5
            Row{
                id: categoryRow
                spacing: 10
                anchors.leftMargin: 30
                anchors.topMargin: 20
                Rectangle{
                    width: 30
                    height: 4
                    color: "#ff961f"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text{
                    id: category
                    text: center.category
                    color: "#ff961f"
                    font.pixelSize: 20
                }
            }
            FontLoader {
                    id: chakraFont
                    source: "qrc:/qt/qml/PiDeck/fonts/ChakraPetch-Bold.ttf"
                }
            Text{
                id: shortDescr
                text: shortDescription
                color: "white"
                font.family: chakraFont.name
                font.pixelSize: 45
            }
            Text{
                id: subt
                text: subtitle
                color: "#9094a0"
                font.pixelSize: 20
            }

            Text{
                id: desc
                text: description
                color: "#c7cad2"
                width: left.width - 30
                wrapMode: Text.WordWrap
                font.pixelSize: 20

            }
        }
    }


    Rectangle {
        id: right
        width: parent.width / 2
        height: parent.height
        color: "black"
        anchors.right: parent.right
        gradient: grad
        Image {
            id: image
            width: parent.width / 2.2
            height: parent.width / 2.2
            sourceSize.width: 600
            sourceSize.height: 600
            source: center.sourceImage
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: 50
            visible: false
            layer.enabled: true
        }
        MultiEffect {
            source: image
            anchors.fill: image
            colorization: 1.0
            colorizationColor: "#ffffff"
            opacity: 0.15
        }
        Rectangle{
            width: textCentre.width + 10
            height: textCentre.height + 10
            color: "transparent"
            border.width: 1
            border.color: "#9094a0"
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.rightMargin: 20
            radius: 5
            Text{
                id: textCentre
                text: center.label
                color: "#9094a0"
                font.pixelSize: 22
                anchors.centerIn: parent
            }
        }
    }
        Gradient{
            id: grad
            orientation: Gradient.Horizontal
                GradientStop { position: 1.0; color: center.colorGlow }
                GradientStop { position: 0.15; color: Qt.darker(center.colorGlow, 100) }
                GradientStop { position: 0.0; color: Qt.rgba(0, 0, 0, 0) }
            }
    Rectangle {
        id: bottomCenterLine
        width: parent.width
        height: 1
        color: Qt.rgba(1, 1, 1, 0.09)
        anchors.bottom: parent.bottom
    }
}