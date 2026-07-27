import QtQuick
import QtQuick.Controls
import PiDeck

Page {
    id: settingsPage

    Rectangle { anchors.fill: parent; color: "black" }

    header: TopPanel { id: topPanel }
    footer: NavigationPanel {
        actions: {
            return [
                    { label: "Navigate", icon: "◀ ▶" },
                    { label: "Open",     icon: "A" },
                    { label: "Back",     icon: "B" }
                ]
        }
    }

    Keys.onEscapePressed: {
            StackView.view.pop()
    }

    Row {
        id: titleRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 15
        anchors.leftMargin: 20
        spacing: 10

        Rectangle {
            id: smallIcon
            width: 60; height: 60
            radius: 20
            color: Theme.tileBg
            gradient: gradientSelcted
            border.width: 1
            border.color: Theme.accent
            Icon {
                source: "qrc:/qt/qml/PiDeck/icons/app.svg"
                sourceSize: 120
                width: 35; height: 35
                anchors.centerIn: parent
                color: Theme.accent
            }
        }
        Text {
            text: "Game"
            color: "white"
            font.pixelSize: 25
            font.bold: true
            anchors.verticalCenter: smallIcon.verticalCenter
        }
    }

    Rectangle {
        id: gamePanel
        anchors.top: titleRow.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.topMargin: 15
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        anchors.bottomMargin: 20
        color: "transparent"
        radius: 20
        border.width: 3
        border.color: Theme.hairline

        GridView {
            id: grid
            anchors.fill: parent
            anchors.margins: 20
            clip: true

            cellWidth: width / 6
            cellHeight: height / 2

            focus: true
            currentIndex: 0
            model: GameTileModel {}

            highlightMoveDuration: 200
            snapMode: GridView.SnapToRow
            highlightRangeMode: GridView.ApplyRange
            preferredHighlightBegin: 0
            preferredHighlightEnd: cellHeight * 2
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar {
                policy: grid.contentHeight > grid.height ? ScrollBar.AsNeeded
                                                         : ScrollBar.AlwaysOff
            }

            delegate: GameTile {
                width: grid.cellWidth
                height: grid.cellHeight
                label: model.label
                img: model.img
                category: model.category
                selected: GridView.isCurrentItem
            }
        }
    }

    Gradient {
        id: gradientSelcted
        GradientStop { position: 0.0; color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}