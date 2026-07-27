import QtQuick
import PiDeck

SelectOverlay {
    title: "Power"
    needConfirm: true
    confirmColor: Theme.danger

    items: [
        { label: "Shutdown", icon: "qrc:/qt/qml/PiDeck/icons/power.svg" },
        { label: "Reboot",   icon: "qrc:/qt/qml/PiDeck/icons/reboot.svg" },
        { label: "Sleep",    icon: "qrc:/qt/qml/PiDeck/icons/sleep.svg" }
    ]

    onChosen: (i) => {
        if (i === 0)      console.log("→ systemctl poweroff")
        else if (i === 1) console.log("→ systemctl reboot")
        else              console.log("→ systemctl suspend")
    }
}