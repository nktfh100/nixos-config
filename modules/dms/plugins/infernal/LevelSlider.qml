import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets

Item {
    id: root
    property string glyph: "volume_up"
    property string label: "Volume"
    property real level: 0
    property bool available: true
    property string unavailableText: "Unavailable"
    signal moved(real value)
    implicitHeight: 66

    DankIcon {
        id: icon
        y: 1
        name: root.glyph
        size: 18
        color: "#d8b9c5"
    }
    Text {
        x: 28
        text: root.label
        font.family: Theme.fontFamily
        font.pixelSize: 12
        color: "#ecdce3"
    }
    Text {
        anchors.right: parent.right
        text: root.available ? Math.round(slider.value) + "%" : root.unavailableText
        font.family: Theme.fontFamily
        font.pixelSize: 11
        color: "#c7aab7"
    }
    Slider {
        id: slider
        x: 0
        y: 23
        width: parent.width
        height: 30
        from: 0
        to: 100
        stepSize: 1
        value: root.level
        enabled: root.available
        focusPolicy: Qt.StrongFocus
        Accessible.name: root.label
        onMoved: root.moved(value)
        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            height: 7
            radius: 3
            color: "#38212e"
            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: parent.radius
                color: slider.enabled ? "#e33955" : "#624352"
            }
        }
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 12
            height: 19
            radius: 4
            color: slider.enabled ? "#ffe7ec" : "#6e5360"
            border.color: slider.activeFocus ? "#ff5364" : "transparent"
            border.width: 2
        }
    }
}
