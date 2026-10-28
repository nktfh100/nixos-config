pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import "../infernal"

PluginComponent {
    id: root
    layerNamespacePlugin: "claude-usage"
    popoutWidth: 420

    property var usage: ({})
    property string error: ""
    property real fetchedAt: 0
    property real now: Date.now()
    readonly property string helper: Qt.resolvedUrl("usage.py").toString().replace("file://", "")
    readonly property url logo: Qt.resolvedUrl("claude.svg")
    readonly property var windowKeys: ["weekly", "session"]
    readonly property var windows: ({
        weekly: Object.assign({ name: "Weekly", short: "W" }, pace(usage.weekly, 7 * 24 * 3600000)),
        session: Object.assign({ name: "5 hours", short: "5h" }, pace(usage.session, 5 * 3600000))
    })
    readonly property bool resetPassed: windowKeys.some(key => windows[key].resets && windows[key].resets <= now)
    readonly property var statusColors: ({ over: "#ff4d5e", limit: "#ff4d5e", track: "#8fd18a" })

    function refresh() {
        if (!fetch.running)
            fetch.running = true;
    }

    function receive(output) {
        try {
            const result = JSON.parse(output);
            error = result.error || "";
            if (!result.error) {
                usage = result;
                fetchedAt = Date.now();
            }
        } catch (_) {
            error = "Usage check failed";
        }
        now = Date.now();
    }

    function pace(window, length) {
        if (!window)
            return { known: false };
        const used = window.percent;
        const resets = window.resetsAt ? Date.parse(window.resetsAt) : 0;
        const left = Math.max(0, resets - now);
        const elapsed = resets ? Math.min(1, Math.max(0, 1 - left / length)) : 0;
        const projected = elapsed > 0 ? used / elapsed : used;
        const status = used >= 100 ? "limit" : !resets ? "idle" : elapsed < 0.1 ? "early" : projected > 100 ? "over" : projected >= 85 ? "track" : "under";
        const runsOut = status === "over" ? now + (100 - used) * elapsed * length / used : 0;
        return { known: true, used, resets, left, elapsed, projected, status, runsOut };
    }

    function duration(ms) {
        const minutes = Math.round(ms / 60000);
        const days = Math.floor(minutes / 1440);
        const hours = Math.floor(minutes % 1440 / 60);
        return days > 0 ? `${days}d ${hours}h` : hours > 0 ? `${hours}h ${minutes % 60}m` : `${minutes}m`;
    }

    function clock(time) {
        const sameDay = new Date(time).toDateString() === new Date(now).toDateString();
        return Qt.formatDateTime(new Date(time), sameDay ? "HH:mm" : "ddd HH:mm");
    }

    function verdict(window) {
        switch (window.status) {
        case "limit": return window.resets ? `Limit reached, back at ${clock(window.resets)}` : "Limit reached";
        case "over": return `Overspending, runs out ${clock(window.runsOut)} (${duration(window.resets - window.runsOut)} early)`;
        case "track": return "On track, you're maxing your plan";
        case "under": return `Underusing, about ${Math.round(100 - window.projected)}% will go to waste`;
        case "early": return "Too early to tell";
        default: return "Not started";
        }
    }

    Process {
        id: fetch
        command: ["python3", root.helper]
        stdout: StdioCollector { onStreamFinished: root.receive(text) }
    }
    Timer { interval: 300000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
    Timer {
        interval: 30000; repeat: true; running: true
        onTriggered: {
            root.now = Date.now();
            if (root.resetPassed)
                root.refresh();
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: 8
            height: root.widgetThickness

            Image { source: root.logo; width: 16; height: 16; sourceSize: Qt.size(32, 32); anchors.verticalCenter: parent.verticalCenter }
            Repeater {
                model: root.windowKeys
                Row {
                    id: pill
                    required property string modelData
                    readonly property var window: root.windows[modelData]
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: pill.window.short
                        color: "#b698a6"
                        font.family: Theme.fontFamily
                        font.pixelSize: Math.round(12 * (root.barConfig?.fontScale ?? 1.0))
                        anchors.baseline: percent.baseline
                    }
                    Text {
                        id: percent
                        text: pill.window.known ? Math.round(pill.window.used) + "%" : "—"
                        color: root.statusColors[pill.window.status] ?? "#f7edf0"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
    verticalBarPill: horizontalBarPill

    popoutContent: Component {
        Item {
            property var parentPopout: null
            readonly property bool presented: parentPopout?.shouldBeVisible ?? false
            onPresentedChanged: if (presented) root.refresh()
            implicitHeight: panel.implicitHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: -Theme.spacingS
                radius: Theme.cornerRadius
                color: Theme.withAlpha("#180b14", 0.94)
            }

            ColumnLayout {
                id: panel
                width: parent.width
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 4
                    Image { source: root.logo; Layout.preferredWidth: 18; Layout.preferredHeight: 18; sourceSize: Qt.size(36, 36) }
                    Text { text: "Claude usage"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 18; Layout.fillWidth: true }
                    Text { visible: !!root.usage.plan; text: (root.usage.plan || "").toUpperCase(); color: "#ff8fa2"; font.family: Theme.fontFamily; font.pixelSize: 12; font.letterSpacing: 1.5 }
                    ActionButton { compact: true; flat: true; diameter: 28; glyph: "refresh"; label: "Refresh"; enabled: !fetch.running; onClicked: root.refresh() }
                }

                Text {
                    visible: !!root.error
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    text: root.error
                    wrapMode: Text.WordWrap
                    color: "#ff4d5e"
                    font.family: Theme.fontFamily
                    font.pixelSize: 14
                }

                Repeater {
                    model: root.windowKeys
                    Rectangle {
                        id: meter
                        required property string modelData
                        readonly property var window: root.windows[modelData]
                        readonly property color tone: root.statusColors[window.status] ?? "#c7aab7"
                        visible: window.known
                        Layout.fillWidth: true
                        implicitHeight: card.implicitHeight + 28
                        radius: 10
                        color: Theme.withAlpha("#1c1019", 0.85)
                        border.color: "#512a3c"

                        ColumnLayout {
                            id: card
                            x: 14; y: 14
                            width: parent.width - 28
                            spacing: 7

                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: meter.window.name; color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 15; Layout.fillWidth: true }
                                Text { text: Math.round(meter.window.used) + "%"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold }
                            }

                            Item {
                                Layout.fillWidth: true
                                implicitHeight: 12
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width; height: 6; radius: 3; color: "#482232"
                                    Rectangle {
                                        width: parent.width * Math.min(1, meter.window.projected / 100); height: parent.height; radius: 3
                                        color: Theme.withAlpha(meter.tone, 0.25)
                                        Behavior on width { NumberAnimation { duration: SettingsData.reduceMotion ? 0 : 400 } }
                                    }
                                    Rectangle {
                                        width: parent.width * Math.min(1, meter.window.used / 100); height: parent.height; radius: 3
                                        color: meter.tone
                                        Behavior on width { NumberAnimation { duration: SettingsData.reduceMotion ? 0 : 400 } }
                                    }
                                }
                                Rectangle {
                                    visible: meter.window.elapsed > 0
                                    x: parent.width * meter.window.elapsed - 1
                                    width: 2; height: parent.height; radius: 1
                                    color: "#f7edf0"
                                }
                            }

                            Text {
                                visible: !!meter.window.resets
                                text: visible ? `Resets ${root.clock(meter.window.resets)}, in ${root.duration(meter.window.left)}` : ""
                                color: "#b698a6"; font.family: Theme.fontFamily; font.pixelSize: 13
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle { width: 6; height: 6; radius: 3; color: meter.tone }
                                Text { text: root.verdict(meter.window); color: meter.tone; font.family: Theme.fontFamily; font.pixelSize: 14; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                                Text {
                                    visible: ["over", "track", "under"].includes(meter.window.status)
                                    text: "→ " + Math.round(meter.window.projected) + "%"
                                    color: "#b698a6"; font.family: Theme.fontFamily; font.pixelSize: 13
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    visible: root.usage.today != null
                    Layout.fillWidth: true
                    implicitHeight: today.implicitHeight + 28
                    radius: 10
                    color: Theme.withAlpha("#1c1019", 0.85)
                    border.color: "#512a3c"

                    RowLayout {
                        id: today
                        x: 14; y: 14
                        width: parent.width - 28
                        Text { text: "Today"; color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 15 }
                        Text { text: "of your weekly limit"; color: "#b698a6"; font.family: Theme.fontFamily; font.pixelSize: 13; Layout.fillWidth: true }
                        Text { text: Math.round(root.usage.today ?? 0) + "%"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold }
                    }
                }

                Text {
                    Layout.margins: 4
                    text: !root.fetchedAt ? "Checking…" : root.now - root.fetchedAt < 60000 ? "Updated just now" : `Updated ${root.duration(root.now - root.fetchedAt)} ago`
                    color: "#987184"; font.family: Theme.fontFamily; font.pixelSize: 12
                }
            }
        }
    }
}
