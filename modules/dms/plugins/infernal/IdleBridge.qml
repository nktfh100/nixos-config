import QtQuick
import Quickshell
import Quickshell.Io
import qs.Services

Item {
    id: root
    readonly property bool preview: Quickshell.env("DMS_LUCIFER_PREVIEW") === "1"
    readonly property bool wanted: !preview && SessionService.idleInhibited

    Process {
        id: inhibitor
        command: ["python3", Qt.resolvedUrl("hardware.py").toString().replace("file://", ""), "--inhibit-lid"]
        stdinEnabled: true
        running: root.wanted
        stderr: StdioCollector {
            onStreamFinished: {
                if (root.wanted && text.trim())
                    ToastService.showError("Stay Awake could not block lid suspend", text.trim());
            }
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: root.wanted
        onTriggered: {
            if (!inhibitor.running)
                inhibitor.running = true;
        }
    }

    onWantedChanged: inhibitor.running = wanted
    Component.onDestruction: inhibitor.running = false
}
