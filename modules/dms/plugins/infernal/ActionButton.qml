import QtQuick
import QtQuick.Controls
import QtQuick.Templates as T
import qs.Common
import qs.Widgets

T.Button {
    id: root

    property string glyph: ""
    property string label: ""
    property string detail: ""
    property bool selected: false
    property bool compact: false
    property int diameter: 44

    implicitWidth: compact ? diameter : 172
    implicitHeight: compact ? diameter : 64
    padding: compact ? 0 : 12
    leftInset: 0
    rightInset: 0
    topInset: 0
    bottomInset: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    Accessible.name: label
    Accessible.description: detail
    HoverHandler {
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    background: Rectangle {
        anchors.fill: parent
        radius: root.compact ? width / 2 : 10
        color: root.down ? "#6c2338" : root.selected ? "#481323" : root.hovered ? "#33202b" : root.flat ? "transparent" : "#21141e"
        border.color: root.visualFocus ? "#f7edf0" : root.selected ? "#c84861" : root.hovered ? "#91536a" : root.flat ? "transparent" : "#593143"
        border.width: root.visualFocus ? 2 : 1
        opacity: root.enabled ? 1 : 0.45
        Behavior on color { ColorAnimation { duration: SettingsData.reduceMotion ? 0 : 130 } }
    }

    contentItem: Item {
        opacity: root.enabled ? 1 : 0.45
        DankIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            x: root.compact ? (parent.width - width) / 2 : 2
            name: root.glyph
            size: 22
            color: root.selected ? "#ff8796" : "#ecd5de"
        }
        Column {
            visible: !root.compact
            anchors.left: icon.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3
            Text {
                width: parent.width
                text: root.label
                color: "#f7edf0"
                font.family: Theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }
            Text {
                width: parent.width
                visible: text.length > 0
                text: root.detail
                color: "#c7aab7"
                font.family: Theme.fontFamily
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }
    }
}
