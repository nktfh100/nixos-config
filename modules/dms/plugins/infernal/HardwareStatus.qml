import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    property var data: ({})
    property string error: ""
    readonly property bool preview: !!Quickshell.env("DMS_LUCIFER_PREVIEW")
    readonly property bool busy: changeProfile.running
    readonly property string profile: data.profile || "Unknown"
    readonly property bool profileAvailable: !!data.profileAvailable
    readonly property bool fast: profile === "Performance"
    readonly property string helper: Qt.resolvedUrl("hardware.py").toString().replace("file://", "")

    function refresh() {
        if (!status.running && !busy)
            status.running = true;
    }
    function toggleProfile() {
        if (preview || busy || !profileAvailable)
            return;
        error = "";
        changeProfile.command = ["python3", helper, "--profile", fast ? "Quiet" : "Performance"];
        changeProfile.running = true;
    }
    function receive(output) {
        try {
            const result = JSON.parse(output);
            data = result;
            if (result.error)
                error = result.error;
        } catch (_) {
            error = "Could not read hardware status";
        }
    }
    Process {
        id: status
        command: ["python3", root.helper]
        stdout: StdioCollector { onStreamFinished: root.receive(text) }
    }
    Process {
        id: changeProfile
        stdout: StdioCollector { onStreamFinished: root.receive(text) }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && !root.error)
                root.error = "ASUS profile change failed";
            root.refresh();
        }
    }
    Timer { interval: root.data.onBattery ? 30000 : 5000; repeat: true; running: true; triggeredOnStart: true; onTriggered: root.refresh() }
}
