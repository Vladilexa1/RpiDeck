import QtQuick

Item {
    id: bottomLine
    height: 50

    Rectangle{
        width: parent.width
        height: parent.height
        color: "#08090c"
        Rectangle{
            width: parent.width
            height: 1
            color: Qt.rgba(255, 255, 255, 0.09)
        }
        Row{
            anchors.fill: parent
            spacing: 10
            anchors.leftMargin: 20
            NavTile{
                label: "Navigate"
                iconComponent: NavigationIcon{ label: "◀  ▶" }
            }
            NavTile{
                label: "Launch"
                iconComponent: NavigationIcon{ label: "L"}
            }
            NavTile{
                label: "Back"
                iconComponent: NavigationIcon { label: "B"}
            }
            NavTile{
                label: "Tweacks"
                iconComponent: NavigationIcon { label: "≡"}
            }
        }
        Text{
            text: "PiDECK  ·  V0.3"
            color: "#5d616d"
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}