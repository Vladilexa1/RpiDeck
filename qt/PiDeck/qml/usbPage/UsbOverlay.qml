import QtQuick
import PiDeck

SelectOverlay {
    title: "USB Mode"
    needConfirm: false

    items: [
        { label: "Keybord + Mouse", icon: "qrc:/qt/qml/PiDeck/assets/icons/usb.svg" },
        { label: "Gamepad",         icon: "qrc:/qt/qml/PiDeck/assets/icons/usb.svg" },
        { label: "Storage",         icon: "qrc:/qt/qml/PiDeck/assets/icons/usb.svg" },
        { label: "Bad usb",         icon: "qrc:/qt/qml/PiDeck/assets/icons/usb.svg" },
        { label: "Usb ethernet",    icon: "qrc:/qt/qml/PiDeck/assets/icons/usb.svg" }
    ]

    onChosen: (i) => {
        if (i === 0)      console.log("→ usb: keybordMouse")
        else if (i === 1) console.log("→ usb: gamepad")
        else if (i === 2) console.log("→ usb: storage")
        else if (i === 3) console.log("→ usb: badUsb")
        else              console.log("→ usb: ethernet")
    }
}