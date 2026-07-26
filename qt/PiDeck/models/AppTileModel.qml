import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListModel{
    ListElement{
        label: "game"
        img: "qrc:/qt/qml/PiDeck/icons/app.svg"
        colorGlow: "#6b2413"
        category: "LIBRARY"
        shortDescription: "GAME LIBRARY"
        subtitle: "RetroPie · Steam · Native · 512 titles"
        description: "Every game in one place — retro emulation through RetroPie, PC titles streamed over Moonlight or Steam Link, and native Linux & indie builds. One grid, one controller."
    }
    ListElement{
        label: "settings"
        img: "qrc:/qt/qml/PiDeck/icons/settings.svg"
        colorGlow: "#40387d"
        category: "SYSTEM"
        shortDescription: "SETTINGS"
        subtitle: "Wi-Fi · Bluetooth · Display · System"
        description: "Connect to Wi-Fi and Bluetooth, tune the display and check system health — all built for the gamepad, no mouse required."
    }
    ListElement{
        label: "music"
        img: "qrc:/qt/qml/PiDeck/icons/music.svg"
        colorGlow: "#653071"
        category: "AUIDO"
        shortDescription: "MUSIC"
        subtitle: "Local library · 3,140 tracks"
        description: "Browse albums and playlists from local storage and stream over Bluetooth or the 3.5mm jack with gapless playback."
    }
    ListElement{
        label: "browser"
        img: "qrc:/qt/qml/PiDeck/icons/browser.svg"
        colorGlow: "#005e67"
        category: "WEB"
        shortDescription: "BROWSER"
        subtitle: "Chromium · gamepad cursor"
        description: "A full web browser tuned for the couch — D-pad spatial navigation, large hit targets and saved shortcuts to your sites."
    }
    ListElement{
        label: "usb"
        img: "qrc:/qt/qml/PiDeck/icons/usb.svg"
        colorGlow: "#016527"
        category: "SYSTEM"
        shortDescription: "SYSTEM TOOLS"
        subtitle: "Be a controller · drive · NIC · BadUSB"
        description: "Plug into any PC and have the console pretend to be something else — a gamepad, keyboard/mouse, USB drive, network adapter, serial console or a scripted HID."
    }
    ListElement{
        label: "terminal"
        img: "qrc:/qt/qml/PiDeck/icons/term.svg"
        colorGlow: "#134e91"
        category: "SYSTEM"
        shortDescription: "TERMINAL"
        subtitle: "bash · pi@deck"
        description: "Drop straight into a shell for tinkering — package installs, service control and the odd git pull, with the radial on-screen keyboard."
    }
    ListElement{
        label: "shutdown"
        img: "qrc:/qt/qml/PiDeck/icons/power.svg"
        colorGlow: "#832931"
        category: "SYSTEM"
        shortDescription: "POWER"
        subtitle: "Shutdown · Reboot · Sleep"
        description: "Safely power down or restart the console. Game progress and downloads are flushed to disk before the system halts."
    }
}
