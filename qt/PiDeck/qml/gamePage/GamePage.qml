import QtQuick
import QtQuick.Controls
import PiDeck
import QtQuick.Layouts

Page {
    id: gamePage

    readonly property var currentGame:
        (grid.model && grid.currentIndex >= 0 && grid.currentIndex < grid.model.count)
            ? grid.model.get(grid.currentIndex)
            : null
    readonly property string currentLable:       currentGame ? currentGame.label       : ""
    readonly property string currentCategory:    currentGame ? currentGame.category    : ""
    readonly property string currentDescription: currentGame ? currentGame.description : ""

    Rectangle { anchors.fill: parent; color: "black" }

    header: TopPanel { id: topPanel }
    footer: NavigationPanel {
        actions: {
            return [
                    { label: "Navigate", icon: "◀ ▲ ▼ ▶" },
                    { label: "Open",     icon: "A" },
                    { label: "Back",     icon: "B" }
                ]
        }
    }

    Keys.onEscapePressed: {
            StackView.view.pop()
    }

    Item {
        id: titleRow
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 15
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        height: 60

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
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
                    source: "qrc:/qt/qml/PiDeck/assets/icons/app.svg"
                    sourceSize: 120
                    width: 35
                    height: 35
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
            color: "transparent"
            width: parent.width / 2
            height: parent.height
            border.width: 3
            radius: 20
            border.color: Theme.hairline
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 15
                    anchors.rightMargin: 15
                    spacing: 6

                    Text {
                        text: gamePage.currentLable + " ·"
                        color: Theme.textBright
                        font.pixelSize: 25
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Text {
                        text: gamePage.currentDescription
                        color: Theme.textBright
                        font.pixelSize: 25
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
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
            readonly property int columns: Math.max(1, Math.round(width / cellWidth))

            Keys.onDownPressed: function(e) {
                const cols = Math.round(width / cellWidth)
                const lastRowStart = count - (count % cols || cols)
                if (currentIndex < lastRowStart && currentIndex + cols >= count)
                    currentIndex = count - 1
                else
                    moveCurrentIndexDown()
                e.accepted = true
            }
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
                policy: grid.contentHeight > grid.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }
            function launchCurrent() {
                    if (!gamePage.currentGame) {
                        console.warn("GamePage: nothing selected")
                        return
                    }
                    console.log("Start game", gamePage.currentLable)
                }
            Keys.onReturnPressed: launchCurrent()
            Keys.onEnterPressed:  launchCurrent()
            Keys.onSpacePressed:  launchCurrent()

            delegate: GameTile {
                width: grid.cellWidth
                height: grid.cellHeight
                label: model.label
                img: model.img
                category: model.category
                description: model.description
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