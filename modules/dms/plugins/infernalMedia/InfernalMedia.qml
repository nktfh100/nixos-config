import QtQuick
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins
import "../infernal"

PluginComponent {
    id: root
    layerNamespacePlugin: "infernal-media"

    readonly property var player: MprisController.activePlayer
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: MprisController.stableTitle || MprisController.displayTrackTitle(player) || player?.identity || "Music"
    readonly property string artist: MprisController.stableArtist || player?.trackArtist || player?.identity || ""
    readonly property string artUrl: TrackArtService.resolvedArtUrl || player?.trackArtUrl || ""
    visible: root.player !== null
    pillClickAction: () => {
        if (root.player?.canTogglePlaying)
            root.player.togglePlaying();
    }

    horizontalBarPill: Component {
        Row {
            spacing: 7
            height: root.widgetThickness

            MediaArtwork {
                width: 28
                height: 28
                anchors.verticalCenter: parent.verticalCenter
                artUrl: root.artUrl
                cornerRadius: 7
            }

            Column {
                width: 160
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    width: parent.width
                    text: root.title
                    color: Theme.surfaceText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    width: parent.width
                    text: root.artist
                    color: Theme.surfaceVariantText
                    font.family: Theme.fontFamily
                    font.pixelSize: Math.round(10 * (root.barConfig?.fontScale ?? 1.0))
                    elide: Text.ElideRight
                }
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0
                ActionButton {
                    compact: true
                    flat: true
                    diameter: 30
                    glyph: "skip_previous"
                    label: "Previous track"
                    enabled: root.player?.canGoPrevious ?? false
                    onClicked: root.player.previous()
                }
                ActionButton {
                    compact: true
                    diameter: 30
                    selected: root.playing
                    glyph: root.playing ? "pause" : "play_arrow"
                    label: root.playing ? "Pause music" : "Play music"
                    enabled: root.player?.canTogglePlaying ?? false
                    onClicked: root.player.togglePlaying()
                }
                ActionButton {
                    compact: true
                    flat: true
                    diameter: 30
                    glyph: "skip_next"
                    label: "Next track"
                    enabled: root.player?.canGoNext ?? false
                    onClicked: root.player.next()
                }
            }
        }
    }
}
