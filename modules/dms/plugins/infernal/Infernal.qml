import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Services
import qs.Widgets
import qs.Common
import qs.Modules.Plugins

PluginComponent {
    id: root
    property int activePage: 0
    property bool panelVisible: false
    layerNamespacePlugin: "infernal"
    popoutWidth: Math.min(820, (parentScreen?.width || 1920) - 36)
    popoutHeight: Math.min(730, (parentScreen?.height || 1080) - 102)

    HardwareStatus { id: machine }
    IdleBridge {}
    Connections {
        target: SettingsData
        function onReduceMotionChanged() {
            if (Quickshell.env("DMS_THEME") === "lucifer" && root.parentScreen?.name === Quickshell.screens[0]?.name)
                Quickshell.execDetached(["lucifer-smoke-mode", SettingsData.reduceMotion ? "off" : "on"]);
        }
    }

    Component.onCompleted: {
        if (!PortalService.profileImage)
            PortalService.profileImage = Qt.resolvedUrl("profile-sigil.svg").toString();
    }

    function openPage(page) {
        const samePage = activePage === page;
        activePage = page;
        if (!panelVisible || samePage)
            triggerPopout();
    }

    horizontalBarPill: Component {
        Item {
            implicitWidth: barContent.implicitWidth + 4
            implicitHeight: root.widgetThickness
            Row {
                id: barContent
                anchors.centerIn: parent
                spacing: 9
                ActionButton {
                    compact: true; flat: true; diameter: 30
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: NetworkService.wifiEnabled ? NetworkService.wifiSignalIcon : "wifi_off"
                    label: NetworkService.wifiConnected ? NetworkService.currentWifiSSID : "Wi-Fi"
                    onClicked: root.openPage(3)
                }
                ActionButton {
                    compact: true; flat: true; diameter: 30
                    anchors.verticalCenter: parent.verticalCenter
                    glyph: BluetoothService.connected ? "bluetooth_connected" : BluetoothService.enabled ? "bluetooth" : "bluetooth_disabled"
                    label: "Bluetooth"
                    onClicked: root.openPage(4)
                }
                Rectangle { width: 1; height: 18; color: "#613146"; anchors.verticalCenter: parent.verticalCenter }
                Row {
                    spacing: 5
                    anchors.verticalCenter: parent.verticalCenter
                    DankIcon { name: AudioService.sink?.audio?.muted ? "volume_off" : "volume_up"; size: 18; color: Theme.surfaceText; anchors.verticalCenter: parent.verticalCenter }
                    Text {
                        text: AudioService.sink?.audio ? Math.round(AudioService.sink.audio.volume * 100) + "%" : "—"
                        color: Theme.surfaceText; font.family: Theme.fontFamily; font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Row {
                    visible: BatteryService.batteryAvailable || !!machine.data.batteryAvailable
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 5
                    DankIcon {
                        name: BatteryService.batteryAvailable ? BatteryService.getBatteryIcon() : machine.data.batteryCharging ? "battery_charging_full" : "battery_5_bar"
                        size: 18; color: Theme.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: Math.round(BatteryService.batteryAvailable ? BatteryService.batteryLevel : machine.data.batteryLevel || 0) + "%"
                        color: Theme.surfaceText; font.family: Theme.fontFamily; font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Image {
                    width: 24
                    height: 24
                    anchors.verticalCenter: parent.verticalCenter
                    source: Qt.resolvedUrl("nix-snowflake.png")
                    sourceSize: Qt.size(48, 48)
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    mipmap: true
                }
            }
        }
    }
    verticalBarPill: horizontalBarPill

    popoutContent: Component {
        InfernalPanel {
            id: panel
            screen: root.parentScreen
            hardware: machine
            page: root.activePage
            onPageChanged: root.activePage = page
            readonly property bool presented: parentPopout?.shouldBeVisible ?? false
            onPresentedChanged: {
                root.panelVisible = presented;
                if (!presented) {
                    panel.cancelDismissal();
                    root.activePage = 0;
                }
            }
            Connections {
                target: root
                function onActivePageChanged() { panel.page = root.activePage; }
            }
        }
    }

}
