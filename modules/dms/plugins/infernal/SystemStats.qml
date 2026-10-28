import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import qs.Common
import qs.Services
import qs.Widgets

GridLayout {
    id: root
    property var hardware: null
    readonly property bool active: visible && (Window.window?.visible ?? false)
    property bool subscribed: false
    columns: width < 640 ? 2 : 4
    columnSpacing: 10
    rowSpacing: 10
    implicitHeight: columns === 4 ? 100 : 210

    function sync() {
        if (active === subscribed)
            return;
        if (active)
            DgopService.addRef(["cpu", "memory"]);
        else
            DgopService.removeRef(["cpu", "memory"]);
        subscribed = active;
    }
    onActiveChanged: sync()
    Component.onCompleted: sync()
    Component.onDestruction: { if (subscribed) DgopService.removeRef(["cpu", "memory"]); }

    readonly property var readings: [
            { icon: "memory", label: "CPU", value: DgopService.dgopAvailable ? Math.round(DgopService.cpuUsage) + "%" : "—", detail: DgopService.cpuFrequency > 0 ? (DgopService.cpuFrequency / 1000).toFixed(1) + " GHz" : "Processor load", level: DgopService.cpuUsage / 100 },
            { icon: "memory_alt", label: "Memory", value: DgopService.totalMemoryMB > 0 ? (DgopService.usedMemoryMB / 1024).toFixed(1) + " GiB" : "—", detail: DgopService.totalMemoryMB > 0 ? "of " + (DgopService.totalMemoryMB / 1024).toFixed(1) + " GiB" : "Waiting for memory", level: DgopService.memoryUsage / 100 },
            { icon: "device_thermostat", label: "CPU temperature", value: DgopService.cpuTemperature > 0 ? Math.round(DgopService.cpuTemperature) + "°C" : "—", detail: DgopService.cpuTemperature >= 85 ? "Running hot" : DgopService.cpuTemperature > 0 ? "Sensor live" : "Sensor unavailable", level: DgopService.cpuTemperature / 100 },
            { icon: "developer_board", label: "dGPU", value: root.hardware?.data.gpuState === "Off" ? "Asleep" : root.hardware?.data.gpuState === "On" ? "Active" : root.hardware?.data.gpuState === "Unavailable" ? "None" : "Unknown", detail: root.hardware?.data.gpuPowerState || "Power state", level: root.hardware?.data.gpuState === "On" ? 1 : 0 }
        ]

    Repeater {
        model: 4
        Rectangle {
            required property int index
            readonly property var modelData: root.readings[index]
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            Layout.minimumWidth: 0
            radius: 10
            color: Theme.withAlpha("#1c1019", 0.35)
            border.color: "#512a3c"
            Row {
                x: 12; y: 12; spacing: 7
                DankIcon { name: modelData.icon; size: 16; color: "#df8d9e" }
                Text { text: modelData.label; color: "#c7aab7"; font.family: Theme.fontFamily; font.pixelSize: 11 }
            }
            Text {
                x: 12; y: 34; width: parent.width - 24
                text: modelData.value
                font.family: Theme.fontFamily
                font.pixelSize: 22
                color: "#f7edf0"
                elide: Text.ElideRight
            }
            Text { x: 12; y: 63; text: modelData.detail; color: "#b698a6"; font.family: Theme.fontFamily; font.pixelSize: 10 }
            Rectangle {
                x: 12; y: 86; width: parent.width - 24; height: 2; radius: 1; color: "#482232"
                Rectangle {
                    width: parent.width * Math.min(1, Math.max(0, modelData.level)); height: 2; radius: 1; color: "#e34562"
                    Behavior on width { NumberAnimation { duration: SettingsData.reduceMotion ? 0 : 400 } }
                }
            }
        }
    }
}
