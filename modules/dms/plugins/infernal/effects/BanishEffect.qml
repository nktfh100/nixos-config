import QtQuick

Item {
    id: root
    property bool reduceMotion: false
    property real phase: 0
    readonly property bool running: sequence.running
    signal finished()
    function banish() {
        if (running) return;
        if (reduceMotion) { finished(); return; }
        sequence.restart();
    }
    function cancel() { sequence.stop(); phase = 0; }
    visible: running
    Rectangle { anchors.fill: parent; radius: 16; color: "#19050e"; opacity: Math.min(0.93, root.phase * 1.6) }
    Sigil {
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) * 0.72
        height: width
        ink: "#dc4a57"
        traced: Math.min(1, root.phase * 2.2)
        scale: 0.82 + root.phase * 0.25
        opacity: root.phase < 0.72 ? 1 : (1 - root.phase) / 0.28
    }
    Rectangle {
        anchors.centerIn: parent
        width: parent.width * root.phase
        height: 2
        color: "#ffc7b7"
        opacity: Math.max(0, 1 - Math.abs(root.phase - 0.73) * 14)
    }
    MouseArea { anchors.fill: parent }
    SequentialAnimation {
        id: sequence
        NumberAnimation { target: root; property: "phase"; from: 0; to: 0.7; duration: 410; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "phase"; to: 1; duration: 230; easing.type: Easing.InCubic }
        ScriptAction { script: root.finished() }
    }
    onReduceMotionChanged: if (reduceMotion && running) { sequence.stop(); finished(); }
}
