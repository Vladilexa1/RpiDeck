import QtQuick
import PiDeck

FocusScope {
    id: panel

    signal exitLeft()

    property bool interactive: true
    property bool wifiActive: false

    property string actionLabel: networks.currentData
                                ? (networks.currentData.connected ? "Disconnect" : "Connect")
                                : ""

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
        }
    }

    function toggleRadio() {
        panel.wifiActive = !panel.wifiActive
    }

    function activateCurrent() {
        if (!panel.wifiActive || !networks.currentData)
            return
        console.log("activate:", networks.currentData.ssid,
                    networks.currentData.connected ? "→ disconnect" : "→ connect")
    }

    onWifiActiveChanged: {
        if (panel.wifiActive)
            Qt.callLater(networks.forceActiveFocus)
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
            text: "Wi-Fi"
            color: "white"
            font.pixelSize: 26
            font.bold: true
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: panel.wifiActive ? networks.count + " networks" : "off"
            color: panel.wifiActive ? "#6f7480" : "#6f7480"
            font.pixelSize: 14
            font.family: "monospace"
        }
    }

    // ── список сетей ──
    ListView {
        id: networks

        anchors.top: head.bottom
        anchors.topMargin: 8
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        visible: panel.wifiActive
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

        model: WifiModel {}

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

    // ── заглушка ──
    Text {
        anchors.centerIn: parent
        text: "Wi-Fi is off · press X to turn on"
        color: "#6f7480"
        font.pixelSize: 16
        font.family: "monospace"
        visible: !panel.wifiActive
    }
}