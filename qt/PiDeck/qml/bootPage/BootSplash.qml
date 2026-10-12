pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import PiDeck

// Start-up screen: the logo plus a short boot log of real checks. Each check
// gets a moment on screen so the log stays readable; any key skips the rest.
FocusScope {
    id: splash

    signal finished()

    property string brandLight: "Pi"
    property string brandAccent: "DECK"

    readonly property int minStepMs: 260
    readonly property int tickMs: 60

    // check() returns { mark, text } once the step is settled, or null to keep
    // waiting; after `wait` ms the step settles on its fallback instead.
    readonly property var steps: [
        {
            label: "probing hardware",
            check: () => ({ mark: "info",
                            text: SystemInfo.model + " · " + SystemInfo.memoryTotalGb + " GB" })
        },
        {
            label: "kernel",
            check: () => ({ mark: "ok", text: SystemInfo.os + " · " + SystemInfo.kernel })
        },
        {
            label: "storage",
            check: () => ({ mark: "info",
                            text: "storage: " + SystemInfo.storageUsedGb + " / "
                                  + SystemInfo.storageTotalGb + " GB used" })
        },
        {
            label: "network",
            wait: 3000,
            check: () => WifiController.connected
                         ? { mark: "ok", text: "network: " + WifiController.connectedSsid }
                         : null,
            fallback: { mark: "info", text: "network: offline" }
        },
        {
            label: "scanning game library",
            check: () => ({ mark: "info", text: "scanning game library … " + games.count + " titles" })
        },
        {
            label: "scanning music",
            check: () => ({ mark: "ok", text: "music library … " + MusicLibrary.count + " tracks" })
        },
        {
            label: "starting PiDeck shell",
            check: () => ({ mark: "info", text: "starting PiDeck shell …" })
        }
    ]

    property int  stepIndex: -1
    property int  stepElapsed: 0
    property bool closing: false

    readonly property real progress: Math.max(0, log.count - (driver.running ? 1 : 0)) / steps.length

    function begin(i) {
        stepIndex = i
        stepElapsed = 0
        log.append({ mark: "wait", text: steps[i].label + " …" })
    }

    function settle(result) {
        log.set(log.count - 1, result)
        if (stepIndex + 1 < steps.length)
            begin(stepIndex + 1)
        else
            close()
    }

    function tick() {
        stepElapsed += tickMs
        if (stepElapsed < minStepMs)
            return
        const step = steps[stepIndex]
        const result = step.check()
        if (result)
            settle(result)
        else if (stepElapsed >= (step.wait || 0))
            settle(step.fallback)
    }

    function close() {
        driver.stop()
        closing = true
    }

    Component.onCompleted: {
        forceActiveFocus()
        begin(0)
        driver.start()
    }

    Keys.onPressed: (e) => {
        close()
        e.accepted = true
    }

    opacity: closing ? 0 : 1
    Behavior on opacity {
        SequentialAnimation {
            NumberAnimation { duration: 450; easing.type: Easing.InOutQuad }
            ScriptAction { script: splash.finished() }
        }
    }

    Timer {
        id: driver
        interval: splash.tickMs
        repeat: true
        onTriggered: splash.tick()
    }

    GameTileModel { id: games }

    ListModel { id: log }

    FontLoader {
        id: chakra
        source: "qrc:/qt/qml/PiDeck/assets/fonts/ChakraPetch-Bold.ttf"
    }

    Rectangle {
        anchors.fill: parent
        color: "#07080b"
        MouseArea { anchors.fill: parent }
    }

    Shape {
        anchors.fill: parent

        ShapePath {
            strokeWidth: -1
            fillGradient: RadialGradient {
                centerX: splash.width / 2
                centerY: splash.height * 0.42
                centerRadius: splash.width * 0.55
                focalX: centerX
                focalY: centerY
                GradientStop { position: 0.0; color: "#1f1610" }
                GradientStop { position: 1.0; color: "#07080b" }
            }
            PathRectangle { width: splash.width; height: splash.height }
        }
    }

    Column {
        id: hero
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -parent.height * 0.12
        spacing: 28

        Row {
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: splash.brandLight
                color: "#f2f2f4"
                font.family: chakra.name
                font.pixelSize: 96
                font.letterSpacing: 8
            }
            // The glow is a blurred copy drawn behind the text rather than an
            // effect on the text itself, so the logo still shows wherever
            // shader effects are unavailable.
            Item {
                width: accentText.width
                height: accentText.height

                MultiEffect {
                    anchors.fill: accentText
                    source: accentText
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 40
                    opacity: 0.7
                }
                Text {
                    id: accentText
                    text: splash.brandAccent
                    color: Theme.accent
                    font.family: chakra.name
                    font.pixelSize: 96
                    font.letterSpacing: 8
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("HANDHELD · LINUX · V%1").arg(SystemInfo.appVersion)
            color: Theme.textDim
            font.pixelSize: 15
            font.letterSpacing: 9
            font.family: "monospace"
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 420
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.07)

            Rectangle {
                height: parent.height
                radius: parent.radius
                width: parent.width * splash.progress
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#e07a0e" }
                    GradientStop { position: 1.0; color: "#ffb45c" }
                }
                Behavior on width { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
            }
        }
    }

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 44
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        spacing: 7

        Repeater {
            model: log

            BootLogLine {}
        }
    }
}
