import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool interactive: true

    // состояние радио живёт в NetworkManager, а не в QML
    readonly property bool wifiActive: NetworkController.radioEnabled

    property string actionLabel: NetworkController.busy
                                 ? "Working…"
                                 : (networks.currentItem
                                    ? (networks.currentItem.connected ? "Disconnect" : "Connect")
                                    : "")

    property string toggleLabel: panel.wifiActive ? "Turn off" : "Turn on"

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
        } else if (e.key === Qt.Key_R) {
            NetworkController.rescan_networks()
            e.accepted = true
        }
    }

    function toggleRadio() {
        NetworkController.set_radio_enabled(!NetworkController.radioEnabled)
    }

    function activateCurrent() {
        if (!panel.wifiActive || NetworkController.busy)
            return

        let tile = networks.currentItem
        if (!tile)
            return

        if (tile.connected)
            NetworkController.disconnect_wifi(tile.ssid)
        else
            NetworkController.connect_to_wifi(tile.ssid, "")
    }

    Component.onCompleted: {
        NetworkController.refresh_radio_state()
        if (NetworkController.radioEnabled)
            NetworkController.rescan_networks()
    }

    onWifiActiveChanged: {
        if (panel.wifiActive)
            NetworkController.rescan_networks()
        else if (panel.activeFocus)
            panel.forceActiveFocus() // список скрыт — клавиши обрабатывает панель
    }

    // Опрос раз в 5 секунд. Режим auto: nmcli сам сканирует радио, когда кэш
    // NetworkManager устаёт — форсировать чаще нельзя, один скан длится ~7 с.
    Timer {
        interval: 5000
        repeat: true
        running: panel.visible && panel.wifiActive && !NetworkController.busy
        onTriggered: NetworkController.refresh_networks()
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
            text: "Wi-Fi"
            color: "white"
            font.pixelSize: 26
            font.bold: true
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: {
                if (!panel.wifiActive)
                    return "off"
                if (NetworkController.scanning)
                    return "scanning…"
                return networks.count + " networks"
            }
            color: Theme.textDim
            font.pixelSize: 14
            font.family: "monospace"
        }
    }

    ListView {
        id: networks

        anchors.top: head.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: error.top
        anchors.bottomMargin: error.visible ? 8 : 0

        visible: panel.wifiActive
        // фокус отдаётся списку биндингом: состояние радио приходит из
        // NetworkManager асинхронно, в том числе до перехода в правую панель
        focus: panel.wifiActive
        clip: true
        spacing: 8
        keyNavigationWraps: true
        highlightMoveDuration: 180
        highlightMoveVelocity: -1

        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 84
        preferredHighlightEnd: height - 84

        model: NetworkController

        delegate: NetworkTile {
            required property var model
            width: networks.width
            height: 76
            ssid: model.ssid
            secured: model.secured
            level: model.level
            connected: model.connected
            security: model.security
            ip: model.ip
            selected: ListView.isCurrentItem && panel.activeFocus
        }
    }

    Text {
        anchors.centerIn: parent
        text: NetworkController.scanning ? "scanning…" : "no networks found · press R to rescan"
        color: Theme.textDim
        font.pixelSize: 16
        font.family: "monospace"
        visible: panel.wifiActive && networks.count === 0
    }

    Text {
        id: error
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        text: NetworkController.lastError
        visible: NetworkController.lastError !== ""
        height: visible ? implicitHeight : 0
        color: "#ff6b6b"
        font.pixelSize: 13
        font.family: "monospace"
        wrapMode: Text.WordWrap
    }

    Text {
        anchors.centerIn: parent
        text: "Wi-Fi is off · press X to turn on"
        color: Theme.textDim
        font.pixelSize: 16
        font.family: "monospace"
        visible: !panel.wifiActive
    }
}
