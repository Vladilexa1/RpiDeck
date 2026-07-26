import QtQuick
import PiDeck

FocusScope {
    id: overlay
    property bool active: false
    property bool confirming: false
    property int confirmIndex: 0   // 0 = Cancel, 1 = Confirm

    signal shutdown()
    signal reboot()
    signal sleep()

    anchors.fill: parent
    visible: opacity > 0
    opacity: active ? 1 : 0
    enabled: active

    Keys.onUpPressed: {
        if (confirming) return
        list.currentIndex = (list.currentIndex + 2) % 3
    }
    Keys.onDownPressed: {
        if (confirming) return
        list.currentIndex = (list.currentIndex + 1) % 3
    }
    Keys.onLeftPressed:  if (confirming) confirmIndex = 0
    Keys.onRightPressed: if (confirming) confirmIndex = 1

    Keys.onReturnPressed: activate()
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_Space) { activate(); e.accepted = true }
    }

    Keys.onEscapePressed: back()

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
    onActiveChanged: {
        if (active) {
            list.currentIndex = 0
            confirming = false
            forceActiveFocus()
        }
    }
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.72)
        MouseArea { anchors.fill: parent }
    }
    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 360
        height: content.implicitHeight + 48
        radius: 20
        color: Theme.surface
        border.width: 1
        border.color: Theme.hairline

        scale: overlay.active ? 1 : 0.92
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Column {
            id: content
            anchors.centerIn: parent
            width: parent.width - 48
            spacing: 18

            Text {
                text: overlay.confirming ? confirmTitle() : "Power"
                color: Theme.textBright
                font.pixelSize: 22
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Column {
                width: parent.width
                spacing: 8
                visible: !overlay.confirming

                Repeater {
                    id: list
                    property int currentIndex: 0

                    model: [
                        { label: "Shutdown", icon: "qrc:/qt/qml/PiDeck/icons/power.svg" },
                        { label: "Reboot",   icon: "qrc:/qt/qml/PiDeck/icons/reboot.svg" },
                        { label: "Sleep",    icon: "qrc:/qt/qml/PiDeck/icons/sleep.svg" }
                    ]

                    Rectangle {
                        width: parent.width
                        height: 54
                        radius: 12
                        color: index === list.currentIndex ? Qt.rgba(1, 1, 1, 0.05)
                                                           : Theme.tileBg
                        border.width: 2
                        border.color: index === list.currentIndex ? Theme.accent : "transparent"

                        Behavior on color        { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 18
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 14

                            Icon {
                                source: modelData.icon
                                width: 22
                                height: 22
                                color: index === list.currentIndex ? Theme.accent : Theme.textMuted
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: modelData.label
                                color: index === list.currentIndex ? Theme.textBright : Theme.textMuted
                                font.pixelSize: 18
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }
                }
            }
            Column {
                width: parent.width
                spacing: 8
                visible: overlay.confirming

                Text {
                    text: "Are you sure?"
                    color: Theme.textMuted
                    font.pixelSize: 15
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 12

                    Rectangle {
                        width: 120; height: 46; radius: 12
                        color: overlay.confirmIndex === 0 ? Qt.rgba(1,1,1,0.05) : Theme.tileBg
                        border.width: 2
                        border.color: overlay.confirmIndex === 0 ? Theme.accent : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Theme.textMuted
                            font.pixelSize: 16
                        }
                    }
                    Rectangle {
                        width: 120; height: 46; radius: 12
                        color: overlay.confirmIndex === 1 ? Qt.rgba(1,0.36,0.12,0.15) : Theme.tileBg
                        border.width: 2
                        border.color: overlay.confirmIndex === 1 ? Theme.danger : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "Confirm"
                            color: overlay.confirmIndex === 1 ? Theme.danger : Theme.textMuted
                            font.pixelSize: 16
                        }
                    }
                }
            }
        }
    }

    function activate() {
        if (!confirming) {
            confirming = true
            confirmIndex = 0
            return
        }
        if (confirmIndex === 0) {       // Cancel
            back()
            return
        }
        // Confirm
        const action = list.currentIndex
        overlay.active = false
        if (action === 0) overlay.shutdown()
        else if (action === 1) overlay.reboot()
        else overlay.sleep()
    }

    function back() {
        if (confirming)
            confirming = false
        else
            overlay.active = false
    }

    function confirmTitle() {
        return ["Shutdown", "Reboot", "Sleep"][list.currentIndex] + "?"
    }
}
