import QtQuick
import PiDeck

// Bottom half of the window that shows the radial keyboard whenever
// Keyboard.open() is called. It keeps its own copy of the text in an input
// line, so the field being edited may stay hidden behind it.
FocusScope {
    id: sheet

    readonly property bool active: Keyboard.active
    property string buffer: ""
    property bool   revealLast: false
    property Item   returnFocus: null

    readonly property string shownText: {
        if (!Keyboard.password)
            return buffer
        if (buffer === "")
            return ""
        const hidden = "•".repeat(buffer.length - 1)
        return hidden + (revealLast ? buffer.charAt(buffer.length - 1) : "•")
    }

    anchors.fill: parent
    visible: opacity > 0
    opacity: active ? 1 : 0
    enabled: active

    Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

    onActiveChanged: {
        if (active) {
            buffer = Keyboard.text
            revealLast = false
            returnFocus = Window.activeFocusItem
            wheel.reset()
            wheel.forceActiveFocus()
        } else {
            if (returnFocus)
                returnFocus.forceActiveFocus()
            returnFocus = null
        }
    }

    Timer {
        id: revealTimer
        interval: 900
        onTriggered: sheet.revealLast = false
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.55)
        MouseArea { anchors.fill: parent }
    }

    Rectangle {
        id: panel
        width: parent.width
        height: Math.round(parent.height * 0.6)
        y: sheet.active ? parent.height - height : parent.height
        color: Theme.surface
        topLeftRadius: 20
        topRightRadius: 20
        border.width: 1
        border.color: Theme.hairline

        Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        Rectangle {
            id: input
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 14
            height: 42
            radius: 10
            color: Theme.tileBg
            border.width: 1
            border.color: Theme.hairline

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.right: layerLabel.left
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                spacing: 14

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Keyboard.title.toUpperCase()
                    color: Theme.textDim
                    font.pixelSize: 12
                    font.letterSpacing: 2
                    font.family: "monospace"
                    visible: text !== ""
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: sheet.shownText
                    color: "white"
                    font.pixelSize: 20
                    font.family: "monospace"
                    elide: Text.ElideLeft
                    width: Math.min(implicitWidth, input.width * 0.6)
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 2
                    height: 22
                    color: Theme.accent

                    SequentialAnimation on opacity {
                        running: sheet.active
                        loops: Animation.Infinite
                        NumberAnimation { to: 0; duration: 500 }
                        NumberAnimation { to: 1; duration: 500 }
                    }
                }
            }

            Text {
                id: layerLabel
                anchors.right: parent.right
                anchors.rightMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("%1 LAYER").arg(wheel.layerName.toUpperCase())
                color: Theme.accent
                font.pixelSize: 12
                font.letterSpacing: 2
                font.family: "monospace"
            }
        }

        RadialKeyboard {
            id: wheel
            anchors.top: input.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 10
            anchors.bottomMargin: 18
            width: height

            onTyped: (text) => {
                sheet.buffer += text
                sheet.revealLast = true
                revealTimer.restart()
            }
            onBackspace: sheet.buffer = sheet.buffer.slice(0, -1)
            onSubmit: Keyboard.accept(sheet.buffer)
            onCancel: Keyboard.reject()
        }

        Column {
            anchors.left: parent.left
            anchors.leftMargin: 28
            anchors.right: wheel.left
            anchors.verticalCenter: wheel.verticalCenter
            spacing: 14

            KeyboardHint { keys: ["Stick", "QWE·ASD·ZXC"]; label: qsTr("group") }
            KeyboardHint { keys: ["Y B A X", "IJKL"]; label: qsTr("key") }
            KeyboardHint { keys: ["Shift"]; label: qsTr("caps") }
        }

        Column {
            anchors.left: wheel.right
            anchors.leftMargin: 28
            anchors.verticalCenter: wheel.verticalCenter
            spacing: 14

            KeyboardHint { keys: ["Start", "Enter"]; label: qsTr("done") }
            KeyboardHint { keys: ["Select", "Esc"]; label: qsTr("cancel") }
            KeyboardHint { keys: ["⌫"]; label: qsTr("erase") }
        }
    }
}
