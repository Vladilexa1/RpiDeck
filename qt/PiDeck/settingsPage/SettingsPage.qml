import QtQuick
import QtQuick.Controls
import PiDeck

Page {
    id: settingsPage

    Rectangle { anchors.fill: parent; color: "black" }

    header: TopPanel { id: topPanel }
    footer: NavigationPanel {
        actions: {
            if (!rightPane.activeFocus)
                return [
                    { label: "Navigate", icon: "▲ ▼" },
                    { label: "Open",     icon: "A" },
                    { label: "Back",     icon: "B" }
                ]

            let a = []
            a.push({ label: "Navigate", icon: "▲ ▼" })

            if (pageLoader.item && pageLoader.item.actionLabel)
                a.push({ label: pageLoader.item.actionLabel, icon: "A" })

            if (pageLoader.item && pageLoader.item.toggleLabel)
                a.push({ label: pageLoader.item.toggleLabel, icon: "X" })

            a.push({ label: "Back", icon: "B" })
            return a
        }
    }

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
                color: Theme.tileBg
                gradient: gradientSelcted
                border.width: 1
                border.color: Theme.accent

                Icon {
                    source: "qrc:/qt/qml/PiDeck/icons/settings.svg"
                    sourceSize: 120
                    width: 35; height: 35
                    anchors.centerIn: parent
                    color: Theme.accent
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
                    color: Theme.textMuted
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
                    border.color: rightPane.activeFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.07)
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
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}