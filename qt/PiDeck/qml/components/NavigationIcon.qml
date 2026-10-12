import QtQuick

Rectangle{
    property string label: ""
    id: launch
    width: launchText.width + 10
    height: launchText.height + 4
    color: Qt.rgba(1, 1, 1, 0.07)
    radius: 5
    border.color: Theme.hairline
    border.width: 2
    Text{
        id: launchText
        text: launch.label
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: 14
    }
}