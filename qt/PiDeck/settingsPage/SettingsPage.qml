import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import PiDeck

Page {
    id: settingsPage

    Rectangle { anchors.fill: parent; color: "black" }

    header: TopPanel { id: topPanel }
    footer: NavigationPanel {}

    Keys.onEscapePressed: {
        if (rightPane.activeFocus)
            leftPane.forceActiveFocus()
        else
            StackView.view.pop()
    }
    Keys.onLeftPressed: {
        if (rightPane.activeFocus)
            leftPane.forceActiveFocus()
    }
    Component.onCompleted: leftPane.forceActiveFocus()

    Column {
        anchors.fill: parent
        anchors.topMargin: 15
        anchors.leftMargin: 20
        spacing: 10

        Row {
            spacing: 10

            Rectangle {
                id: smallIcon
                width: 60
                height: 60
                radius: 20
                color: Qt.rgba(255, 255, 255, 0.045)
                gradient: gradientSelcted
                border.width: 1
                border.color: "#ff961f"

                Image {
                    id: icon
                    source: "qrc:/qt/qml/PiDeck/icons/settings.svg"
                    sourceSize.width: 120
                    sourceSize.height: 120
                    width: 35
                    height: 35
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    layer.enabled: true
                }

                MultiEffect {
                    source: icon
                    anchors.fill: icon
                    colorization: 1.0
                    colorizationColor: "#ff961f"
                    Behavior on colorizationColor { ColorAnimation { duration: 150 } }
                }
            }

            Column {
                spacing: 10

                Text {
                    text: "Settings"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }

                Text {
                    text: "Wi-Fi"
                    color: "#9094a0"
                    font.pixelSize: 16
                }
            }
        }

        Row {
            id: panes
            spacing: 10
            width: parent.width
            height: parent.height - y
            FocusScope {
                id: leftPane
                width: 260
                height: parent.height

                ListView {
                    id: list

                    property var currentData: (currentIndex >= 0 && currentIndex < count ?
                                               list.model.get(currentIndex) : null)

                    focus: true
                    keyNavigationEnabled: true
                    Keys.onRightPressed: {
                        if (pageLoader.item && pageLoader.item.exitLeft)
                            rightPane.forceActiveFocus()
                    }
                    Keys.onReturnPressed: rightPane.forceActiveFocus()
                    anchors.fill: parent
                    orientation: ListView.Vertical
                    clip: true
                    spacing: 10
                    currentIndex: 0
                    model: SettingsTileModel {}
                    highlightMoveDuration: 300
                    highlightMoveVelocity: -1

                    delegate: SettingsTile {
                        width: list.width
                        height: 50
                        label: model.label
                        img: model.img
                        selected: ListView.isCurrentItem
                        dimmed: !leftPane.activeFocus
                    }
                }
            }

            FocusScope {
                id: rightPane
                width: parent.width - leftPane.width - parent.spacing - 10
                height: parent.height - 10

                Rectangle {
                    anchors.fill: parent
                    radius: 20
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.width: 1
                    border.color: rightPane.activeFocus ? "#ff961f" : Qt.rgba(1, 1, 1, 0.07)
                    Behavior on border.color { ColorAnimation { duration: 50 } }

                    Loader {
                        id: pageLoader
                        anchors.fill: parent
                        anchors.margins: 20
                        focus: true
                        source: list.currentData ? list.currentData.page : ""

                        onLoaded: {
                            if (item.exitLeft)
                                item.exitLeft.connect(() => leftPane.forceActiveFocus())
                        }
                    }
                }
            }
        }
    }

    Gradient {
        id: gradientSelcted
        GradientStop { position: 0.0; color: Qt.rgba(255/255, 150/255, 31/255, 0.3) }
        GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0) }
    }
}