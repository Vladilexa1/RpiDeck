import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: win
    width: 1024
    height: 600
    visible: true

    StackView {
        id: stack
        anchors.fill: parent
        initialItem: homePage
        pushEnter: Transition {}
        pushExit: Transition {}
        popEnter: Transition {}
        popExit: Transition {}
    }

    Component {
        id: homePage
        Page {
            Rectangle { anchors.fill: parent; color: "black" }
            header: TopPanel { id: topPanel }
            footer: NavigationPanel {}

            CentreMainLayer {
                anchors.top: parent.top
                anchors.bottom: appLayer.top
                anchors.bottomMargin: 35
                anchors.left: parent.left
                anchors.right: parent.right
                tile: appLayer.currentData
            }
            AppLayer {
                id: appLayer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 125
                Component.onCompleted: forceActiveFocus()
                Keys.onReturnPressed: openCurrent()
                Keys.onPressed: (e) => { if (e.key === Qt.Key_Space) openCurrent() }
                function openCurrent() {
                    if (currentData && currentData.label === "settings")
                        stack.push("SettingsPage.qml")
                    if (currentData && currentData.label === "game")
                        stack.push("GamePage.qml")
                    if (currentData && currentData.label === "terminal")
                        stack.push("GamePage.qml")
                }
            }
        }
    }
}
