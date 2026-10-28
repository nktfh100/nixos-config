import QtQuick
import Quickshell.Hyprland
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root
    layerNamespacePlugin: "infernal-spaces"

    readonly property var regularSpaces: Array.from(Hyprland.workspaces?.values || [])
        .filter(workspace => workspace.id > 0 && workspace.monitor?.name === root.parentScreen?.name)
        .sort((a, b) => a.id - b.id)

    readonly property var occupiedSpaces: ["S", "DEV"].filter(name =>
        Array.from(Hyprland.toplevels?.values || []).some(window => window.workspace?.name === "special:" + name))

    readonly property real labelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)

    component SpaceChip: Rectangle {
        id: chip
        property string label
        property bool active
        signal activated

        width: Math.max(height, chipLabel.implicitWidth + Theme.spacingS * 2)
        height: Math.round(root.widgetThickness * 0.7)
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: active ? Theme.primary : Theme.surfaceTextAlpha

        StyledText {
            id: chipLabel
            anchors.centerIn: parent
            text: chip.label
            color: "white"
            font.pixelSize: root.labelSize
            font.weight: chip.active ? Font.Bold : Font.Medium
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.activated()
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS
            height: root.barThickness

            Repeater {
                model: root.regularSpaces

                SpaceChip {
                    label: modelData.name
                    active: modelData.active
                    onActivated: modelData.activate()
                }
            }

            Repeater {
                model: root.occupiedSpaces

                SpaceChip {
                    label: modelData
                    active: CompositorService.hyprlandVisibleSpecialWorkspaceOnScreen(root.parentScreen?.name) === "special:" + modelData
                    onActivated: HyprlandService.toggleSpecial(modelData)
                }
            }
        }
    }
}
