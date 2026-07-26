import QtQuick

FocusScope {
    id: panel
    signal exitLeft()

    Keys.onLeftPressed: panel.exitLeft()
    Keys.onEscapePressed: panel.exitLeft()
    Text {
        anchors.centerIn: parent
        text: "Display panel"
        color: "white"
        font.pixelSize: 24
    }
}
