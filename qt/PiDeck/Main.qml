import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PiDeck

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
            footer: NavigationPanel {
                actions: [
                    { label: "Navigate", icon: "◀ ▶" },
                    { label: "Launch",   icon: "A" },
                    { label: "Tweaks",   icon: "≡" }
                ]
            }

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
                    if (!currentData) return
                    if (currentData.label === "settings")
                        stack.push("settingsPage/SettingsPage.qml")
                    else if (currentData.label === "game")
                        stack.push("GamePage.qml")
                    else if (currentData.label === "terminal")
                        stack.push("GamePage.qml")
                    else if (currentData.label === "shutdown")
                        power.active = true
                }
            }
        }
    }
    PowerOverlay {
        id: power
        onShutdown: console.log("→ systemctl poweroff")
        onReboot:   console.log("→ systemctl reboot")
        onSleep:    console.log("→ systemctl suspend")
        onActiveChanged: if (!active && stack.currentItem)
                             stack.currentItem.forceActiveFocus()
    }
}