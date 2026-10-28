import QtQuick
import QtQuick.Window
import qs.Widgets
import qs.Common
import qs.Services

Item {
    id: root
    property var player: MprisController.activePlayer
    property real progress: player && player.length > 0 ? Math.min(1, player.position / player.length) : 0
    property bool playing: player?.isPlaying ?? false
    readonly property bool hasArt: !!(player && (player.trackArtUrl || (player.metadata && player.metadata["mpris:artUrl"])))
    property bool moving: playing && !SettingsData.reduceMotion && visible && (Window.window?.visible ?? false)
    property real phase: 0
    property bool spectrumSubscribed: false
    implicitWidth: 290
    implicitHeight: 284

    function updateSubscription() {
        const next = moving;
        if (next === spectrumSubscribed)
            return;
        spectrumSubscribed = next;
        CavaService.refCount += next ? 1 : -1;
    }
    onMovingChanged: { updateSubscription(); orbit.requestPaint(); }
    onPlayerChanged: orbit.requestPaint()
    Component.onCompleted: updateSubscription()
    Component.onDestruction: {
        if (spectrumSubscribed)
            CavaService.refCount--;
    }

    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: 24000
        loops: Animation.Infinite
        running: root.moving
    }
    onPhaseChanged: orbit.requestPaint()
    onProgressChanged: orbit.requestPaint()
    Connections {
        target: CavaService
        function onValuesChanged() { if (root.moving) orbit.requestPaint(); }
    }
    Canvas {
        id: orbit
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const cx = width / 2, cy = height / 2, radius = Math.min(width, height) * 0.345;
            ctx.lineWidth = 1;
            ctx.strokeStyle = "#663046";
            ctx.beginPath(); ctx.arc(cx, cy, radius + 17, 0, Math.PI * 2); ctx.stroke();
            for (let i = 0; i < 72; i++) {
                const angle = i / 72 * Math.PI * 2 - Math.PI / 2;
                const value = root.moving && CavaService.cavaAvailable ? (CavaService.values[i % 6] || 0) / 45 : 0;
                const length = (i % 6 === 0 ? 8 : 3) + Math.min(22, value * 22);
                ctx.strokeStyle = root.player && i / 72 < root.progress ? "#ff7b8d" : "#894059";
                ctx.lineWidth = i % 6 === 0 ? 2 : 1;
                ctx.beginPath();
                ctx.moveTo(cx + Math.cos(angle) * (radius + 24), cy + Math.sin(angle) * (radius + 24));
                ctx.lineTo(cx + Math.cos(angle) * (radius + 24 + length), cy + Math.sin(angle) * (radius + 24 + length));
                ctx.stroke();
            }
            if (root.player) {
                if (root.player.length > 0) {
                    ctx.strokeStyle = "#ff5364";
                    ctx.lineWidth = 3;
                    ctx.beginPath(); ctx.arc(cx, cy, radius + 9, -Math.PI / 2, -Math.PI / 2 + root.progress * Math.PI * 2); ctx.stroke();
                }
                if (root.moving) {
                    ctx.fillStyle = "#ffe7ed";
                    ctx.beginPath(); ctx.arc(cx + Math.cos(root.phase) * (radius + 17), cy + Math.sin(root.phase) * (radius + 17), 2.4, 0, Math.PI * 2); ctx.fill();
                }
            }
        }
    }

    MediaBlobHalo {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * .72
        height: width
        accentColor: "#ff5364"
        playing: root.moving
        visible: root.hasArt
    }
    MediaArtwork {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * .72 * .88
        height: width
        cornerRadius: width / 2
        artUrl: root.player?.trackArtUrl || root.player?.metadata?.["mpris:artUrl"] || ""
        visible: root.hasArt
    }
    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * .72 * .88
        height: width
        radius: width / 2
        color: Theme.withAlpha("#180b14", 0.35)
        border.color: "#77243c"
        border.width: 2
        visible: !root.hasArt

        Image {
            anchors.centerIn: parent
            width: 84
            height: 84
            source: Qt.resolvedUrl("nix-snowflake.png")
            fillMode: Image.PreserveAspectFit
        }
    }
}
