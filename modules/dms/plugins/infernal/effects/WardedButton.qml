import QtQuick
import QtQuick.Controls

Button {
    id: root
    property bool warded: false
    property bool reduceMotion: false
    property real seal: warded ? 1 : 0
    implicitWidth: 190
    implicitHeight: 64
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: "Do not disturb: " + (warded ? "on, ward sealed" : "off, ward broken")
    Accessible.checkable: true
    Accessible.checked: warded
    Behavior on seal { NumberAnimation { duration: root.reduceMotion ? 0 : 720; easing.type: Easing.InOutCubic } }
    background: Rectangle {
        radius: 10
        color: root.down ? "#512035" : root.warded ? "#341526" : "#21101c"
        border.color: root.activeFocus ? "#f9eaf0" : root.hovered ? "#f2859c" : root.warded ? "#be5470" : "#633049"
        border.width: root.activeFocus ? 2 : 1
    }
    contentItem: Item {
        Sigil {
            x: 1; anchors.verticalCenter: parent.verticalCenter
            width: 44; height: 44
            ward: true
            traced: 0.12 + root.seal * 0.88
            ink: root.warded ? "#ff9bb0" : "#987184"
            rotation: root.reduceMotion ? 0 : (1 - root.seal) * -72
            opacity: 0.48 + root.seal * 0.52
        }
        Column {
            x: 53; anchors.verticalCenter: parent.verticalCenter; spacing: 4
            Text { text: "Do not disturb"; color: "#f9eaf0"; font.pixelSize: 12 }
            Text { text: root.warded ? "Ward sealed · On" : "Ward broken · Off"; color: "#c7aab7"; font.pixelSize: 10 }
        }
    }
}
