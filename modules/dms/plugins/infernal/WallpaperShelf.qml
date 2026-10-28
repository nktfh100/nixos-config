import QtQuick
import QtQuick.Controls
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Services

Column {
    id: root
    property var wallpapers: []
    property var selectedWallpaper: ({})
    property string errorMessage: ""
    function apply(action, value) {
        if (update.running) return;
        errorMessage = "";
        update.command = ["theme-wallpaper", action, value];
        update.running = true;
    }
    Process {
        id: update
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.error) root.errorMessage = result.error;
                    else root.selectedWallpaper = result;
                } catch (error) { root.errorMessage = "Wallpaper service unavailable"; }
            }
        }
        onExited: (code, status) => { if (code !== 0) root.errorMessage = "Wallpaper service unavailable"; }
    }
    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/desktop-theme/" + Quickshell.env("DMS_THEME") + "/wallpaper.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.selectedWallpaper = JSON.parse(text()); } catch (error) {} }
    }
    width: parent.width
    spacing: 18

    FileView {
        path: Qt.resolvedUrl("wallpapers.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.wallpapers = JSON.parse(text()); }
            catch (error) { console.error("Wallpaper catalogue:", error); }
        }
    }

    Text { text: "Choose your wallpaper"; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 18 }
    Text { visible: root.errorMessage.length > 0; text: root.errorMessage; color: "#ff8796"; font.family: Theme.fontFamily; font.pixelSize: 12 }

    Grid {
        id: grid
        width: parent.width
        columns: root.width < 500 ? 1 : 2
        spacing: 14
        Repeater {
            model: root.wallpapers
            Button {
                id: option
                required property var modelData
                width: (root.width - grid.spacing * (grid.columns - 1)) / grid.columns
                height: 190
                property bool selected: root.selectedWallpaper.id === modelData.id
                padding: 0
                focusPolicy: Qt.StrongFocus
                Accessible.name: modelData.title + " wallpaper"
                Accessible.description: selected ? "Selected" : "Apply wallpaper"
                onClicked: root.apply("select", modelData.id)
                background: Rectangle {
                    radius: 10
                    color: "#21141e"
                    border.width: option.activeFocus ? 2 : 1
                    border.color: option.activeFocus ? "#f7edf0" : option.selected ? "#ff5364" : "#613146"
                }
                contentItem: Column {
                    width: option.width
                    spacing: 12
                    Image {
                        x: 5; y: 5
                        width: parent.width - 10; height: 140
                        source: "file://" + option.modelData.path
                        fillMode: Image.PreserveAspectCrop
                        sourceSize.width: 600
                        asynchronous: true
                    }
                    RowLayout {
                        x: 14; width: parent.width - 28
                        Text { text: option.modelData.title; color: "#f7edf0"; font.family: Theme.fontFamily; font.pixelSize: 12; Layout.fillWidth: true }
                        Text { text: "Selected"; visible: option.selected; color: "#ff91a4"; font.family: Theme.fontFamily; font.pixelSize: 10 }
                    }
                }
            }
        }
    }
}
