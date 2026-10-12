import QtQuick

Item {
    id: navTile
    width: row.width
    height: 50
    property string label: ""
    property string icon: ""

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8
        NavigationIcon {
            label: navTile.icon
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: navTile.label
            color: Theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
