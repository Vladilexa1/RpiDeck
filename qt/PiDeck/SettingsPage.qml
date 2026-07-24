import QtQuick
import QtQuick.Controls

Page {
    id: settingsPage
    Rectangle { anchors.fill: parent; color: "black" }

    focus: true
    Keys.onEscapePressed: StackView.view.pop()
    Component.onCompleted: forceActiveFocus()
    header: TopPanel { id: topPanel }
    footer: NavigationPanel {}

}