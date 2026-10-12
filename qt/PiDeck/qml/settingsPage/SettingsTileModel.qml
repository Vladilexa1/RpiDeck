import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ListModel{
    ListElement{
        label: "Wi-Fi"
        img: "qrc:/qt/qml/PiDeck/assets/icons/wifi-full.svg"
        page: "qrc:/qt/qml/PiDeck/qml/settingsPage/panels/WifiPanel.qml"
    }
    ListElement{
        label: "Bluetooth"
        img: "qrc:/qt/qml/PiDeck/assets/icons/bluetooth.svg"
        page: "qrc:/qt/qml/PiDeck/qml/settingsPage/panels/BluetoothPanel.qml"
    }
    ListElement{
        label: "Display"
        img: "qrc:/qt/qml/PiDeck/assets/icons/display.svg"
        page: "qrc:/qt/qml/PiDeck/qml/settingsPage/panels/DisplayPanel.qml"
    }
    ListElement{
        label: "System"
        img: "qrc:/qt/qml/PiDeck/assets/icons/cpu.svg"
        page: "qrc:/qt/qml/PiDeck/qml/settingsPage/panels/SystemPanel.qml"
    }
    ListElement{
        label: "About"
        img: "qrc:/qt/qml/PiDeck/assets/icons/about.svg"
        page: "qrc:/qt/qml/PiDeck/qml/settingsPage/panels/AboutPanel.qml"
    }
}
