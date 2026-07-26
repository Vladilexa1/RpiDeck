import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool interactive: true
    property bool bluetoothActive: false

    // подпись кнопки A — теперь только про устройство
    property string actionLabel: bluetooth.currentData
                                ? (bluetooth.currentData.connected ? "Disconnect" : "Connect")
                                : ""

    // подпись кнопки X — про радио. Пустая строка = кнопки нет
    property string toggleLabel: panel.bluetoothActive ? "Turn off" : "Turn on"

    focus: true

    Keys.onLeftPressed: panel.exitLeft()
    Keys.onEscapePressed: panel.exitLeft()
    Keys.onReturnPressed: panel.activateCurrent()
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_Space) {
            panel.activateCurrent()
            e.accepted = true
        } else if (e.key === Qt.Key_X) {
            panel.toggleRadio()
            e.accepted = true
        }
    }

    function toggleRadio() {
        panel.bluetoothActive = !panel.bluetoothActive
    }

    function activateCurrent() {
        if (!panel.bluetoothActive || !bluetooth.currentData)
            return
        console.log("activate:", bluetooth.currentData.name,
                    bluetooth.currentData.connected ? "→ disconnect" : "→ connect")
    }

    // фокус следует за состоянием радио
    onBluetoothActiveChanged: {
        if (panel.bluetoothActive)
            bluetooth.forceActiveFocus()
        else
            panel.forceActiveFocus()
    }
    // ── шапка ──
    Item {
        id: head
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 44

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Bluetooth"
            color: "white"
            font.pixelSize: 26
            font.bold: true
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: panel.bluetoothActive ? "on" : "off"
            color: panel.bluetoothActive ? "#ff961f" : "#6f7480"
            font.pixelSize: 14
            font.family: "monospace"
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // ── список устройств ──
    ListView {
        id: bluetooth

        anchors.top: head.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: panel.bluetoothActive
        clip: true
        spacing: 8
        keyNavigationWraps: true
        highlightMoveDuration: 180
        highlightMoveVelocity: -1

        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 84
        preferredHighlightEnd: height - 84

        property var currentData: (currentIndex >= 0 && currentIndex < count)
                                  ? model.get(currentIndex) : null

        model: BluetoothModel {}

        delegate: BluetoothTile {
            required property var model
            width: bluetooth.width
            height: 76
            name: model.name
            type: model.type
            battery: model.battery
            paired: model.paired
            connected: model.connected
            selected: ListView.isCurrentItem && panel.activeFocus
        }
    }

    // ── заглушка при выключенном Bluetooth ──
    Text {
        anchors.centerIn: parent
        text: "Bluetooth is off · press A to turn on"
        color: "#6f7480"
        font.pixelSize: 16
        font.family: "monospace"
        visible: !panel.bluetoothActive
    }
}