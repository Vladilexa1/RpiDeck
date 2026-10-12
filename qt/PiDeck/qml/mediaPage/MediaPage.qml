import QtQuick
import QtQuick.Controls
import QtMultimedia
import PiDeck

Page {
    id: mediaPage

    readonly property int currentTrack: player.trackIndex
    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState

    function formatTime(ms) {
        if (ms <= 0)
            return "0:00"

        let total = Math.floor(ms / 1000)
        let minutes = Math.floor(total / 60)
        let seconds = total % 60
        return minutes + ":" + (seconds < 10 ? "0" : "") + seconds
    }

    function playRow(row) {
        if (row < 0 || row >= MusicLibrary.count)
            return

        player.trackIndex = row
        player.source = MusicLibrary.sourceAt(row)
        player.play()
    }

    function activateCurrent() {
        if (tracks.currentIndex === player.trackIndex && player.trackIndex >= 0) {
            if (mediaPage.playing)
                player.pause()
            else
                player.play()
            return
        }
        playRow(tracks.currentIndex)
    }

    function playNext() {
        if (MusicLibrary.count === 0)
            return
        playRow((player.trackIndex + 1) % MusicLibrary.count)
    }

    Rectangle { anchors.fill: parent; color: "black" }

    header: TopPanel {}
    footer: NavigationPanel {
        actions: [
            { label: "Navigate",            icon: "▲ ▼" },
            { label: mediaPage.playing ? "Pause" : "Play", icon: "A" },
            { label: "Seek",                icon: "◀ ▶" },
            { label: "Back",                icon: "B" }
        ]
    }

    MediaPlayer {
        id: player

        // The list index this source came from: MediaPlayer itself has no idea
        // which row of the library is on air.
        property int trackIndex: -1

        audioOutput: AudioOutput { id: output; volume: 0.7 }

        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.EndOfMedia)
                mediaPage.playNext()
        }
    }

    Keys.onEscapePressed: StackView.view.pop()
    Keys.onReturnPressed: mediaPage.activateCurrent()
    Keys.onLeftPressed: player.position = Math.max(0, player.position - 10000)
    Keys.onRightPressed: player.position = Math.min(player.duration, player.position + 10000)
    Keys.onPressed: (e) => {
        if (e.key === Qt.Key_Space || e.key === Qt.Key_A) {
            mediaPage.activateCurrent()
            e.accepted = true
        } else if (e.key === Qt.Key_R) {
            MusicLibrary.refresh()
            e.accepted = true
        } else if (e.key === Qt.Key_Plus || e.key === Qt.Key_Equal) {
            output.volume = Math.min(1, output.volume + 0.1)
            e.accepted = true
        } else if (e.key === Qt.Key_Minus) {
            output.volume = Math.max(0, output.volume - 0.1)
            e.accepted = true
        }
    }

    Component.onCompleted: {
        MusicLibrary.refresh()
        tracks.forceActiveFocus()
    }

    Column {
        anchors.fill: parent
        anchors.topMargin: 15
        anchors.leftMargin: 20
        anchors.rightMargin: 20
        spacing: 10

        Row {
            spacing: 10

            Rectangle {
                width: 60
                height: 60
                radius: 20
                color: Theme.tileBg
                border.width: 1
                border.color: Theme.accent

                Icon {
                    source: "qrc:/qt/qml/PiDeck/assets/icons/music.svg"
                    sourceSize: 120
                    width: 35; height: 35
                    anchors.centerIn: parent
                    color: Theme.accent
                }
            }

            Column {
                spacing: 10

                Text {
                    text: "Media"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }
                Text {
                    text: MusicLibrary.count + " tracks · " + MusicLibrary.folder
                    color: Theme.textMuted
                    font.pixelSize: 14
                    font.family: "monospace"
                    elide: Text.ElideMiddle
                    width: mediaPage.width - 140
                }
            }
        }

        Item {
            width: parent.width - 20
            height: parent.height - y - nowPlaying.height - 20

            ListView {
                id: tracks
                anchors.fill: parent

                focus: true
                clip: true
                spacing: 8
                keyNavigationWraps: true
                highlightMoveDuration: 180
                highlightMoveVelocity: -1
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: 72
                preferredHighlightEnd: height - 72

                model: MusicLibrary

                delegate: TrackTile {
                    required property var model
                    required property int index

                    width: tracks.width
                    height: 64
                    title: model.title
                    album: model.album
                    selected: ListView.isCurrentItem
                    current: index === player.trackIndex
                    playing: mediaPage.playing
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: MusicLibrary.count === 0

                Text {
                    text: "No music found"
                    color: Theme.textMuted
                    font.pixelSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: "put files into " + MusicLibrary.folder + " · press R to rescan"
                    color: Theme.textDim
                    font.pixelSize: 14
                    font.family: "monospace"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    Rectangle {
        id: nowPlaying

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20
        height: 74
        radius: 14
        color: Qt.rgba(1, 1, 1, 0.03)
        border.width: 1
        border.color: Theme.hairline

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Row {
                width: parent.width

                Text {
                    text: player.trackIndex >= 0
                          ? MusicLibrary.titleAt(player.trackIndex)
                          : "nothing playing"
                    color: player.trackIndex >= 0 ? "white" : Theme.textDim
                    font.pixelSize: 17
                    elide: Text.ElideRight
                    width: parent.width - timeText.implicitWidth - 12
                }
                Text {
                    id: timeText
                    text: mediaPage.formatTime(player.position) + " / "
                          + mediaPage.formatTime(player.duration)
                          + "   vol " + Math.round(output.volume * 100) + "%"
                    color: Theme.textDim
                    font.pixelSize: 14
                    font.family: "monospace"
                }
            }

            Rectangle {
                width: parent.width
                height: 6
                radius: 3
                color: Theme.hairline

                Rectangle {
                    height: parent.height
                    radius: 3
                    color: Theme.accent
                    width: player.duration > 0
                           ? parent.width * player.position / player.duration
                           : 0
                }
            }
        }
    }
}
