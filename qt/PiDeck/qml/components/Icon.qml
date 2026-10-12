import QtQuick
import QtQuick.Effects

Item {
    id: root
    property url source: ""
    property color color: Theme.textMuted
    property int sourceSize: 64
    property bool animateColor: false
    property int colorDuration: 150

    implicitWidth: 24
    implicitHeight: 24

    Image {
        id: img
        anchors.fill: parent
        source: root.source
        sourceSize.width: root.sourceSize
        sourceSize.height: root.sourceSize
        fillMode: Image.PreserveAspectFit
        layer.enabled: true
        visible: false
    }
    MultiEffect {
        source: img
        anchors.fill: img
        colorization: 1.0
        colorizationColor: root.color
        Behavior on colorizationColor {
            enabled: root.animateColor
            ColorAnimation { duration: root.colorDuration }
        }
    }
}
