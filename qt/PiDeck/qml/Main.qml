import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PiDeck

Window {
    id: win
    width: 1024
    height: 600
    visible: true

    // Opened in the system's default browser; the browser needs some page to
    // land on, so the deck keeps its own start page here.
    property url browserHome: "https://www.google.com"

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
//  Test keybord on main page -> f2 key                
//Keys.onPressed: (e) => {
//     if (e.key === Qt.Key_Space) openCurrent()
//     else if (e.key === Qt.Key_F2)
//         Keyboard.open({ title: "Test", password: false },
//                       t => console.log("typed:", t),
//                       () => console.log("cancelled"))
// }
                function openCurrent() {
                    if (!currentData) return
                    if (currentData.label === "settings")
                        stack.push("settingsPage/SettingsPage.qml")
                    else if (currentData.label === "game")
                        stack.push("gamePage/GamePage.qml")
                    else if (currentData.label === "media")
                        stack.push("mediaPage/MediaPage.qml")
                    else if (currentData.label === "browser")
                        SystemController.openUrl(win.browserHome)
                    else if (currentData.label === "usb")
                        usb.active = true
                    else if (currentData.label === "shutdown")
                        power.active = true
                }
            }
        }
    }
    PowerOverlay {
        id: power
        onActiveChanged: if (!active && stack.currentItem)
                             stack.currentItem.forceActiveFocus()
    }
    UsbOverlay {
        id: usb
        onActiveChanged: if (!active && stack.currentItem)
                             stack.currentItem.forceActiveFocus()
    }
    KeyboardSheet {}
    Loader {
        id: boot
        anchors.fill: parent
        sourceComponent: BootSplash {
            onFinished: boot.active = false
        }
        onActiveChanged: if (!active && stack.currentItem)
                             stack.currentItem.forceActiveFocus()
    }
}