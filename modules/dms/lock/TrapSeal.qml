import QtQuick

Item {
    id: root
    property bool reduceMotion: false
    property real traced: 0
    property real fracture: 0
    property color ink: "#dcb7bd"
    function reset() {
        draw.stop();
        release.stop();
        fracture = 0;
        traced = reduceMotion ? 1 : 0;
    }
    function seal() {
        reset();
        if (!reduceMotion) draw.restart();
    }
    function breakSeal() {
        draw.stop();
        traced = 1;
        if (reduceMotion) fracture = 1;
        else release.restart();
    }
    Image { id: artwork; source: "devils-trap.jpg"; visible: false; smooth: true }
    ShaderEffect {
        anchors.fill: parent
        property variant source: artwork
        property real traced: root.traced
        property real fracture: root.fracture
        property color ink: root.ink
        fragmentShader: Qt.resolvedUrl("trap.frag.qsb")
    }
    NumberAnimation { id: draw; target: root; property: "traced"; from: 0; to: 1; duration: 760; easing.type: Easing.InOutCubic }
    NumberAnimation { id: release; target: root; property: "fracture"; from: 0; to: 1; duration: 520; easing.type: Easing.InCubic }
    Component.onCompleted: reset()
    onReduceMotionChanged: {
        if (!reduceMotion) return;
        if (release.running) { release.stop(); fracture = 1; }
        if (draw.running) { draw.stop(); traced = 1; }
    }
}
