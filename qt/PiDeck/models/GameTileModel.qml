import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListModel{
    ListElement{
        label: "Minecraft"
        img: "qrc:/qt/qml/PiDeck/images/test.png"
        category: "BUILDING"
        description: "Every game in one place — retro emulation through RetroPie, PC titles streamed over Moonlight or Steam Link, and native Linux & indie builds. One grid, one controller."
    }
    ListElement{
        label: "MOHAA"
        img: "qrc:/qt/qml/PiDeck/images/test2.png"
        category: "SHOOTER"
        description: "Browse albums and playlists from local storage and stream over Bluetooth or the 3.5mm jack with gapless playback."
    }
    ListElement{
        label: "Serius Sam"
        img: "qrc:/qt/qml/PiDeck/images/test.png"
        category: "SHOOTER"
        description: "A full web browser tuned for the couch — D-pad spatial navigation, large hit targets and saved shortcuts to your sites."
    }
}
