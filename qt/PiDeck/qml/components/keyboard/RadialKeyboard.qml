pragma ComponentBehavior: Bound
import QtQuick
import PiDeck

// Daisywheel keyboard: the stick (or QWE/ASD/ZXC) picks a group, a face button
// (or IJKL) picks the key inside it. It only reports what was typed, so the
// same wheel can feed a text field here or a system-wide input device later.
FocusScope {
    id: wheel

    signal typed(string text)
    signal backspace()
    signal submit()
    signal cancel()

    // Groups run clockwise from the top; the top-left one holds the editing
    // keys. Keys inside a group follow the face buttons: Y, B, A, X.
    readonly property int editGroup: 7
    readonly property var layers: [
        { name: "abc", groups: ["abcd", "efgh", "ijkl", "mnop", "qrst", "uvwx", "yz,."] },
        { name: "123", groups: ["1234", "5678", "90-_", "@#$%", "&*()", "!?:;", "'\"/+"] },
        { name: "#+=", groups: ["<=>~", "[]{}", "\\|^`", "€£¥§", "°±×÷", "«»¡¿", "…·•¶"] }
    ]

    property int  group: 0
    property int  layerIndex: 0
    property bool caps: false

    // Where the stick points, -1..1 on both axes; drawn as the centre dot.
    property real stickX: 0
    property real stickY: -0.6

    readonly property string layerName: layerIndex === 0 && caps ? "ABC" : layers[layerIndex].name

    readonly property var labels: {
        const upper = layerIndex === 0 && caps
        const out = layers[layerIndex].groups.map(keys => [0, 1, 2, 3].map(i => {
            const ch = keys.charAt(i)
            return upper ? ch.toUpperCase() : ch
        }))
        out.push(["␣", "⌫", "↵", layers[(layerIndex + 1) % layers.length].name])
        return out
    }

    readonly property var groupKeys: ({
        [Qt.Key_W]: 0, [Qt.Key_E]: 1, [Qt.Key_D]: 2, [Qt.Key_C]: 3,
        [Qt.Key_X]: 4, [Qt.Key_Z]: 5, [Qt.Key_A]: 6, [Qt.Key_Q]: 7,
        [Qt.Key_Up]: 0, [Qt.Key_Right]: 2, [Qt.Key_Down]: 4, [Qt.Key_Left]: 6
    })
    readonly property var buttonKeys: ({
        [Qt.Key_I]: 0, [Qt.Key_L]: 1, [Qt.Key_K]: 2, [Qt.Key_J]: 3
    })

    function reset() {
        layerIndex = 0
        caps = false
        selectGroup(0)
    }

    function selectGroup(g) {
        group = g
        const angle = g * Math.PI / 4
        stickX = Math.sin(angle) * 0.6
        stickY = -Math.cos(angle) * 0.6
    }

    // For an analog stick: a deflection past the dead zone picks the group it
    // points at; letting go keeps the last one so a face button can follow.
    function setStick(x, y) {
        stickX = x
        stickY = y
        if (Math.hypot(x, y) < 0.5)
            return
        const step = Math.round(Math.atan2(x, -y) / (Math.PI / 4))
        group = (step + 8) % 8
    }

    function press(button) {
        if (group !== editGroup) {
            const ch = labels[group][button]
            if (ch !== "")
                typed(ch)
            return
        }
        switch (button) {
        case 0: typed(" "); break
        case 1: backspace(); break
        case 2: submit(); break
        case 3: layerIndex = (layerIndex + 1) % layers.length; break
        }
    }

    Keys.onPressed: (e) => {
        if (e.key in groupKeys)
            selectGroup(groupKeys[e.key])
        else if (e.key in buttonKeys)
            press(buttonKeys[e.key])
        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
            submit()
        else if (e.key === Qt.Key_Escape)
            cancel()
        else if (e.key === Qt.Key_Backspace)
            backspace()
        else if (e.key === Qt.Key_Space)
            typed(" ")
        else if (e.key === Qt.Key_Shift || e.key === Qt.Key_Tab)
            caps = !caps
        e.accepted = true
    }

    readonly property real tileSize: Math.min(width, height) / 3.95
    readonly property real ringRadius: tileSize * 1.45

    Repeater {
        model: 8

        KeyGroupTile {
            required property int index

            width: wheel.tileSize
            height: wheel.tileSize
            x: wheel.width / 2 + Math.sin(index * Math.PI / 4) * wheel.ringRadius - width / 2
            y: wheel.height / 2 - Math.cos(index * Math.PI / 4) * wheel.ringRadius - height / 2
            labels: wheel.labels[index]
            selected: index === wheel.group
        }
    }

    Rectangle {
        id: hub
        anchors.centerIn: parent
        width: wheel.tileSize * 0.9
        height: width
        radius: width / 2
        color: Theme.tileBg
        border.width: 1
        border.color: Theme.hairline

        Rectangle {
            width: 12
            height: 12
            radius: 6
            color: Theme.accent
            x: (hub.width - width) / 2 + wheel.stickX * (hub.width - width) / 2
            y: (hub.height - height) / 2 + wheel.stickY * (hub.height - height) / 2
        }
    }
}
