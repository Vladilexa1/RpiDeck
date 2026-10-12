import QtQuick

ListView{
    id: list
    property var currentData: (currentIndex >= 0 && currentIndex < count ?
                                   list.model.get(currentIndex) : null)

    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: width / 2 - 125 / 2
    preferredHighlightEnd:   width / 2 + 125 / 2
    focus: true
    currentIndex: 0
    orientation: ListView.Horizontal
    spacing: 10
    model: AppTileModel{}
    highlightMoveDuration: 300
    highlightMoveVelocity: -1
    Behavior on contentX {
        NumberAnimation {
            duration: 10
            easing.type: Easing.OutCubic
        }
    }
    delegate: AppTile{
        width: 125
        height: 125
        label: model.label
        selected: ListView.isCurrentItem
        img: model.img
        colorGlow: model.colorGlow
        category: model.category
    }
}