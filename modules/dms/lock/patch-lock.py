from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()


def replace(old, new):
    global text
    if text.count(old) != 1:
        raise SystemExit(
            "DMS lock source changed; review the Infernal lock patch: " + old
        )
    text = text.replace(old, new)


replace(
    "import QtQuick\n", 'import QtQuick\nimport Quickshell\nimport "InfernalEffects"\n'
)
replace(
    '        unlocking = false;\n        pamState = "";',
    '        unlocking = false;\n        infernalEntranceStarted = false;\n        infernalUnlockDelay.stop();\n        infernalTrap.reset();\n        pamState = "";',
)
replace(
    '    property bool unlocking: false',
    '    property bool unlocking: false\n    property bool infernalEntranceStarted: false',
)
replace(
    '        Qt.callLater(() => {\n            if (root.visible && root.opacity > 0 && !root.unlocking)',
    '        if (!infernalEntranceStarted && Quickshell.env("DMS_THEME") === "lucifer") {\n            infernalEntranceStarted = true;\n            infernalTrap.seal();\n        }\n        Qt.callLater(() => {\n            if (root.visible && root.opacity > 0 && !root.unlocking)',
)
replace(
    "    WidgetEditLayer {\n        id: widgetLayer",
    """    TrapSeal {
        id: infernalTrap
        visible: Quickshell.env("DMS_THEME") === "lucifer"
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, parent.height * 0.86)
        height: width
        opacity: 0.38
        ink: root.pamState === "fail" ? "#ff5364" : "#dcb7bd"
        reduceMotion: SettingsData.reduceMotion
    }

    Timer {
        id: infernalUnlockDelay
        interval: Quickshell.env("DMS_THEME") === "lucifer" && !SettingsData.reduceMotion ? 540 : 1
        onTriggered: root.unlockRequested()
    }

    WidgetEditLayer {
        id: widgetLayer""",
)
replace(
    '            root.passwordEdited("");\n            root.unlockRequested();',
    '            root.passwordEdited("");\n            infernalTrap.breakSeal();\n            infernalUnlockDelay.restart();',
)
path.write_text(text)

lock_path = path.with_name("Lock.qml")
lock_text = lock_path.read_text()
old = '        buffer: root.sharedPasswordBuffer\n        onUnlockRequested: root.unlock()'
if lock_text.count(old) != 1:
    raise SystemExit("DMS lock source changed; review the Infernal unlock patch: " + old)
lock_path.write_text(
    lock_text.replace(
        old,
        '        buffer: root.sharedPasswordBuffer\n'
        '        onUnlockRequested: {\n'
        '            if (Quickshell.env("DMS_THEME") !== "lucifer")\n'
        '                root.unlock();\n'
        '        }',
    )
)
