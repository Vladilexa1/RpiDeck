import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListModel{
    ListElement{
        label: "Wi-Fi"
        img: "qrc:/qt/qml/PiDeck/icons/wifi-full.svg"
        page: "qrc:/qt/qml/PiDeck/settingsPage/panels/WifiPanel.qml"
    }
    ListElement{
        label: "Bluetooth"
        img: "qrc:/qt/qml/PiDeck/icons/bluetooth.svg"
        page: "qrc:/qt/qml/PiDeck/settingsPage/panels/BluetoothPanel.qml"
    }
    ListElement{
        label: "Display"
        img: "qrc:/qt/qml/PiDeck/icons/display.svg"
        page: "qrc:/qt/qml/PiDeck/settingsPage/panels/DisplayPanel.qml"
    }
    ListElement{
        label: "System"
        img: "qrc:/qt/qml/PiDeck/icons/cpu.svg"
        page: "qrc:/qt/qml/PiDeck/settingsPage/panels/SystemPanel.qml"
    }
    ListElement{
        label: "About"
        img: "qrc:/qt/qml/PiDeck/icons/about.svg"
        page: "qrc:/qt/qml/PiDeck/settingsPage/panels/AboutPanel.qml"
    }
}
