import QtQuick
Item {

    id: navTile
    width: row.width
    height: 50
    property string label: ""
    property Component iconComponent: null
    Row{
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        Loader {
            sourceComponent: navTile.iconComponent
            anchors.verticalCenter: parent.verticalCenter
        }
        Text{
            text: navTile.label
            color: "#9094a0"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
