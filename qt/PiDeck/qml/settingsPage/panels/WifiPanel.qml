import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool interactive: true

    readonly property bool wifiActive: WifiController.radioEnabled

    property string actionLabel: WifiController.busy
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
        } else if (e.key === Qt.Key_A) {
            panel.activateCurrent()
            e.accepted = true
        }
    }

    // A secured network is first tried without a password, so one nmcli
    // already has saved connects straight away; only a refusal opens the
    // keyboard to ask for it.
    property string passwordlessSsid: ""

    Connections {
        target: WifiController

        function onConnectSucceeded(ssid) {
            panel.passwordlessSsid = ""
        }

        function onConnectFailed(ssid, error) {
            if (ssid !== panel.passwordlessSsid)
                return
            panel.passwordlessSsid = ""
            Keyboard.open({ title: qsTr("Password · %1").arg(ssid), password: true },
                          password => WifiController.connectTo(ssid, password))
        }
    }

    function toggleRadio() {
        WifiController.setRadioEnabled(!WifiController.radioEnabled)
    }

    function activateCurrent() {
        if (!panel.wifiActive || WifiController.busy)
            return

        let tile = networks.currentItem
        if (!tile)
            return

        if (tile.connected) {
            WifiController.disconnectCurrent()
            return
        }
        panel.passwordlessSsid = tile.secured ? tile.ssid : ""
        WifiController.connectTo(tile.ssid)
    }

    Component.onCompleted: {
        WifiController.refreshRadioState()
        if (WifiController.radioEnabled)
            WifiController.rescan()
    }

    onWifiActiveChanged: {
        if (panel.wifiActive)
            WifiController.rescan()
        else if (panel.activeFocus)
            panel.forceActiveFocus()
    }

    Timer {
        interval: 5000
        repeat: true
        running: panel.visible && panel.wifiActive && !WifiController.busy
        onTriggered: WifiController.refresh()
    }

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
                if (WifiController.scanning)
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
        focus: panel.wifiActive
        clip: true
        spacing: 8
        keyNavigationWraps: true
        highlightMoveDuration: 180
        highlightMoveVelocity: -1

        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: 84
        preferredHighlightEnd: height - 84

        model: WifiController.networks

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
        text: WifiController.scanning ? "scanning…" : "no networks found · press R to rescan"
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
        text: WifiController.lastError
        visible: WifiController.lastError !== ""
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
