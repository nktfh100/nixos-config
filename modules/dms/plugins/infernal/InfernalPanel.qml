import QtQuick
import "effects"
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.ControlCenter.Details

Item {
    id: root
    property var screen: null
    property var closePopout: null
    property var parentPopout: null
    property int page: 0
    property var hardware: null
    readonly property bool onScreen: Window.window?.visible ?? false
    readonly property bool narrow: width < 680
    readonly property var player: MprisController.activePlayer
    implicitHeight: Math.min(716, (screen?.height || 1080) - 116)

    function formatTime(value) {
        const seconds = Math.max(0, Math.floor(value || 0));
        return Math.floor(seconds / 60) + ":" + (seconds % 60).toString().padStart(2, "0");
    }
    function cancelDismissal() { banishing.cancel(); }
    function finish() { if (closePopout) closePopout(); }

    SystemClock { id: clock; precision: SystemClock.Minutes }

    Rectangle {
        x: 12
        y: 0
        width: parent.width - 24
        height: 1
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#4c172c" }
            GradientStop { position: .5; color: "#ff687e" }
            GradientStop { position: 1; color: "#4c172c" }
        }
    }
    RowLayout {
        id: header
        x: 14
        y: 15
        width: parent.width - 28
        height: 44
        spacing: 10
        Image { source: Qt.resolvedUrl("sigil.svg"); Layout.preferredWidth: 28; Layout.preferredHeight: 28 }
        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: "#f9eaf0"
            font.family: Theme.fontFamily
            font.pixelSize: 24
        }
        Text {
            visible: !root.narrow
            text: Qt.formatDateTime(clock.date, "ddd, d MMM")
            color: "#c7aab7"
            font.family: Theme.fontFamily
            font.pixelSize: 11
            Layout.fillWidth: true
        }
        Item { Layout.fillWidth: true; visible: root.narrow }
        Repeater {
            model: [
                { glyph: "tune", label: "Controls" },
                { glyph: "wallpaper", label: "Wallpapers" },
                { glyph: "notifications", label: "History" }
            ]
            ActionButton {
                required property var modelData
                required property int index
                compact: true
                glyph: modelData.glyph
                label: modelData.label
                selected: root.page === index
                onClicked: root.page = index
            }
        }
        Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 24; color: "#563040" }
        ActionButton { compact: true; glyph: "settings"; label: "Settings"; onClicked: { root.finish(); PopoutService.openSettings(); } }
        ActionButton { compact: true; glyph: "power_settings_new"; label: "Power menu"; onClicked: { root.finish(); Quickshell.execDetached(["theme-power"]); } }
        ActionButton { compact: true; glyph: "close"; label: "Close panel"; onClicked: banishing.banish() }
    }

    Flickable {
        id: content
        x: 14
        y: 77
        width: parent.width - 28
        height: parent.height - y - 12
        clip: true
        contentWidth: width
        contentHeight: root.page === 0 ? controls.implicitHeight : root.page === 1 ? wallpapers.implicitHeight : root.page === 2 ? history.implicitHeight : connectivity.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { }

        GridLayout {
            columns: root.narrow ? 1 : 2
            rowSpacing: 18
            columnSpacing: 22
            id: controls
            visible: root.page === 0
            width: parent.width

            Rectangle {
                Layout.fillWidth: root.narrow
                Layout.preferredWidth: root.narrow ? controls.width : 326
                Layout.preferredHeight: (root.screen?.height || 1080) < 900 ? 460 : 490
                radius: 12
                color: Theme.withAlpha("#180b14", 0.35)
                border.color: "#542039"

                RadialMedia {
                    id: radial
                    x: 10
                    y: 13
                    width: parent.width - 20
                    height: 284
                    player: root.player
                    visible: root.page === 0
                }
                Column {
                    x: 22
                    y: 294
                    width: parent.width - 44
                    spacing: 8
                    Text {
                        width: parent.width
                        text: MprisController.stableTitle || "Nothing playing"
                        font.family: Theme.fontFamily
                        font.pixelSize: 19
                        font.weight: Font.Medium
                        color: "#f7edf0"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Text {
                        width: parent.width
                        text: MprisController.stableArtist || ""
                        visible: text.length > 0
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        color: "#c7aab7"
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 14
                        topPadding: 13
                        ActionButton {
                            compact: true; glyph: "skip_previous"; label: "Previous track"
                            enabled: root.player?.canGoPrevious ?? false
                            onClicked: MprisController.previousOrRewind()
                        }
                        ActionButton {
                            compact: true; glyph: root.player?.isPlaying ? "pause" : "play_arrow"
                            label: root.player?.isPlaying ? "Pause" : "Play"
                            selected: true
                            enabled: root.player?.canTogglePlaying ?? false
                            onClicked: root.player.togglePlaying()
                        }
                        ActionButton {
                            compact: true; glyph: "skip_next"; label: "Next track"
                            enabled: root.player?.canGoNext ?? false
                            onClicked: MprisController.next()
                        }
                    }
                    Slider {
                        id: seek
                        width: parent.width
                        from: 0
                        to: Math.max(1, root.player?.length || 0)
                        value: root.player?.position || 0
                        enabled: root.player?.canSeek ?? false
                        Accessible.name: "Track position"
                        onMoved: root.player.position = value
                        background: Rectangle {
                            x: seek.leftPadding
                            y: seek.topPadding + seek.availableHeight / 2 - height / 2
                            width: seek.availableWidth
                            height: 3
                            radius: 2
                            color: "#532536"
                            Rectangle { width: seek.visualPosition * parent.width; height: parent.height; radius: 2; color: "#ff687e" }
                        }
                        handle: Rectangle {
                            x: seek.leftPadding + seek.visualPosition * (seek.availableWidth - width)
                            y: seek.topPadding + seek.availableHeight / 2 - height / 2
                            width: 7; height: 7; radius: 4
                            color: "#ffe6ee"
                            visible: seek.enabled
                        }
                    }
                    RowLayout {
                        width: parent.width
                        Text { text: root.formatTime(root.player?.position); color: "#bd9eac"; font.family: Theme.fontFamily; font.pixelSize: 10 }
                        Item { Layout.fillWidth: true }
                        Text { text: root.formatTime(root.player?.length); color: "#bd9eac"; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 12
                Text { text: "Quick controls"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 15; Layout.bottomMargin: 2 }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    WardedButton {
                        Layout.fillWidth: true
                        warded: SessionData.doNotDisturb
                        reduceMotion: SettingsData.reduceMotion
                        onClicked: SessionData.setDoNotDisturb(!SessionData.doNotDisturb)
                    }
                    ActionButton {
                        Layout.fillWidth: true
                        glyph: root.hardware?.fast ? "speed" : "coffee"
                        label: "PC mode"
                        detail: root.hardware?.busy ? "Switching…" : !root.hardware?.profileAvailable ? "ASUS unavailable" : (root.hardware.fast ? "Fast" : root.hardware.profile === "Quiet" ? "Battery · quiet" : "Balanced") + (root.hardware.preview ? " · preview" : "")
                        selected: root.hardware?.fast ?? false
                        enabled: !!root.hardware?.profileAvailable && !root.hardware?.busy && !root.hardware?.preview
                        onClicked: root.hardware.toggleProfile()
                    }
                    ActionButton {
                        Layout.fillWidth: true
                        glyph: SessionService.idleInhibited ? "visibility" : "bedtime"
                        label: "Stay awake"
                        detail: SessionService.idleInhibited ? "On · lid ignored" : "Off · sleep allowed"
                        selected: SessionService.idleInhibited
                        onClicked: SessionService.toggleIdleInhibit()
                    }
                    ActionButton {
                        Layout.fillWidth: true
                        glyph: "content_paste"
                        label: "Clipboard"
                        detail: "Search history"
                        onClicked: { root.finish(); PopoutService.openClipboardHistory(); }
                    }
                    ActionButton {
                        Layout.fillWidth: true
                        glyph: NetworkService.wifiEnabled ? NetworkService.wifiSignalIcon : "wifi_off"
                        label: "Wi-Fi"
                        detail: !NetworkService.networkAvailable ? "Unavailable" : NetworkService.wifiToggling ? "Switching…" : !NetworkService.wifiEnabled ? "Off" : NetworkService.wifiConnected ? NetworkService.currentWifiSSID || "Connected" : "On · not connected"
                        selected: NetworkService.networkAvailable && NetworkService.wifiEnabled
                        enabled: NetworkService.networkAvailable && !NetworkService.wifiToggling
                        onClicked: NetworkService.toggleWifiRadio()
                    }
                    ActionButton {
                        Layout.fillWidth: true
                        glyph: BluetoothService.connected ? "bluetooth_connected" : BluetoothService.enabled ? "bluetooth" : "bluetooth_disabled"
                        label: "Bluetooth"
                        detail: !BluetoothService.available ? "Unavailable" : BluetoothService.connected ? "Connected" : BluetoothService.enabled ? "On" : "Off"
                        selected: BluetoothService.enabled
                        enabled: BluetoothService.available
                        onClicked: BluetoothService.toggleBluetooth()
                    }
                }
                Text {
                    Layout.fillWidth: true
                    visible: !!root.hardware?.error
                    text: root.hardware?.error || ""
                    color: "#ff8796"
                    font.family: Theme.fontFamily
                    font.pixelSize: 11
                    wrapMode: Text.WordWrap
                }
                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: "#51283b"; Layout.topMargin: 6; Layout.bottomMargin: 6 }
                LevelSlider {
                    Layout.fillWidth: true
                    label: "Volume"
                    glyph: AudioService.sink?.audio?.muted ? "volume_off" : "volume_up"
                    level: (AudioService.sink?.audio?.volume || 0) * 100
                    available: !!AudioService.sink?.audio
                    unavailableText: "No output"
                    onMoved: value => AudioService.setVolume(value)
                }
                LevelSlider {
                    Layout.fillWidth: true
                    label: "Brightness"
                    glyph: "brightness_6"
                    level: DisplayService.brightnessLevel
                    available: DisplayService.brightnessAvailable && !Quickshell.env("DMS_LUCIFER_PREVIEW")
                    unavailableText: Quickshell.env("DMS_LUCIFER_PREVIEW") ? "Preview" : "No backlight"
                    onMoved: value => DisplayService.setBrightness(value)
                }
            }
            SystemStats {
                Layout.columnSpan: root.narrow ? 1 : 2
                Layout.fillWidth: true
                hardware: root.hardware
            }
        }

        WallpaperShelf {
            id: wallpapers
            width: parent.width
            visible: root.page === 1
        }

        Column {
            id: connectivity
            width: parent.width
            spacing: 18
            visible: root.page === 3 || root.page === 4
            RowLayout {
                width: parent.width
                ActionButton { compact: true; glyph: "arrow_back"; label: "Back to controls"; onClicked: root.page = 0 }
                Text { text: root.page === 3 ? "Wi-Fi & network" : "Bluetooth"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 19; Layout.fillWidth: true }
            }
            Text {
                width: parent.width
                visible: root.page === 3 ? !NetworkService.networkAvailable : !BluetoothService.available
                text: Quickshell.env("DMS_LUCIFER_PREVIEW") ? "Device controls are unavailable in this isolated preview." : root.page === 3 ? "No network adapter available." : "No Bluetooth adapter available."
                color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
            Loader {
                width: parent.width
                height: active ? 430 : 0
                active: root.page === 3 && NetworkService.networkAvailable
                sourceComponent: Component { NetworkDetail { selectedType: "wifi" } }
            }
            Loader {
                width: parent.width
                height: active ? 430 : 0
                active: root.page === 4 && BluetoothService.available
                sourceComponent: Component { BluetoothDetail {} }
            }
        }

        Column {
            id: history
            width: parent.width
            spacing: 14
            visible: root.page === 2
            RowLayout {
                width: parent.width
                Text { text: "Notification history"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 18; Layout.fillWidth: true }
                ActionButton {
                    compact: true; glyph: "delete_sweep"; label: "Clear history"
                    enabled: NotificationService.historyList.length > 0
                    onClicked: NotificationService.clearHistory()
                }
            }
            Repeater {
                model: NotificationService.historyList
                Rectangle {
                    required property var modelData
                    width: history.width
                    implicitHeight: cardContent.implicitHeight + 30
                    color: Theme.withAlpha("#21141e", 0.35)
                    radius: 10
                    border.color: "#583044"
                    Column {
                        id: cardContent
                        x: 16; y: 15; width: parent.width - 32; spacing: 7
                        RowLayout {
                            width: parent.width
                            Text { text: modelData.appName || "Notification"; color: "#ff8fa2"; font.pixelSize: 11; font.family: Theme.fontFamily; Layout.fillWidth: true }
                            Text { text: modelData.timestamp ? Qt.formatDateTime(new Date(modelData.timestamp), "HH:mm") : ""; color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 11 }
                            ActionButton { compact: true; glyph: "close"; label: "Remove notification"; onClicked: NotificationService.removeFromHistory(modelData.id) }
                        }
                        Text { width: parent.width; text: modelData.summary || ""; textFormat: Text.PlainText; wrapMode: Text.WordWrap; color: "#f7edf0"; font.pixelSize: 14; font.family: Theme.fontFamily }
                        Text { width: parent.width; text: modelData.body || ""; textFormat: Text.PlainText; wrapMode: Text.WordWrap;  color: "#c7aab7"; font.pixelSize: 12; font.family: Theme.fontFamily }
                    }
                }
            }
            Item {
                width: parent.width
                height: 280
                visible: NotificationService.historyList.length === 0
                Column {
                    anchors.centerIn: parent
                    spacing: 22
                    Image { anchors.horizontalCenter: parent.horizontalCenter; source: Qt.resolvedUrl("sigil.svg"); width: 48; height: 48; opacity: .65 }
                    Text { text: "No notifications yet"; color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 14 }
                }
            }
        }
    }
    BanishEffect {
        id: banishing
        anchors.fill: parent
        z: 100
        reduceMotion: SettingsData.reduceMotion
        onFinished: root.finish()
    }
}
