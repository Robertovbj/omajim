import QtQuick
import QtQuick.Controls

// Vimium's link hints (f): a label on everything that can be clicked;
// typing one clicks there, or puts the cursor in a field. Esc gives up.
// It lies over the whole window, the header too, in window coordinates.
Item {
    id: overlay
    objectName: "hintLayer"

    readonly property var ui: theme.colors
    property var targets: []
    property string typed: ""
    // Where the focus was, for the keys to go on from there.
    property Item focusBefore: null

    anchors.fill: parent
    z: 1000
    visible: false

    function start() {
        const found = linkHints.targets(win)
        if (found.length === 0)
            return
        const labels = linkHints.labels(found.length)
        targets = found.map((target, i) => ({item: target.item, x: target.x, y: target.y, label: labels[i]}))
        typed = ""
        focusBefore = win.activeFocusItem
        visible = true
        catcher.forceActiveFocus()
    }
    function stop() {
        if (!visible)
            return
        visible = false
        targets = []
        typed = ""
        if (focusBefore)
            focusBefore.forceActiveFocus()
        focusBefore = null
    }
    function type(letter) {
        const next = typed + letter
        const matches = targets.filter(target => target.label.startsWith(next))
        if (matches.length === 0)
            return
        typed = next
        if (matches.length === 1 && matches[0].label === next) {
            const item = matches[0].item
            stop()
            linkHints.click(item)
        }
    }

    Item {
        id: catcher
        // Every key is a letter of a label here, never a shortcut.
        Keys.onShortcutOverride: event => event.accepted = true
        Keys.onPressed: event => {
            event.accepted = true
            if (event.key === Qt.Key_Escape)
                overlay.stop()
            else if (event.key === Qt.Key_Backspace)
                overlay.typed = overlay.typed.slice(0, -1)
            else if (event.text.length === 1 && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier)))
                overlay.type(event.text.toLowerCase())
        }
        // A click elsewhere, or the window left behind, ends it.
        onActiveFocusChanged: if (!activeFocus && overlay.visible) overlay.stop()
    }

    Repeater {
        model: overlay.targets
        Rectangle {
            required property var modelData
            readonly property bool matches: modelData.label.startsWith(overlay.typed)
            visible: matches
            x: Math.min(modelData.x, overlay.width - width)
            y: Math.min(modelData.y, overlay.height - height)
            width: hint.implicitWidth + 8
            height: hint.implicitHeight + 2
            radius: Math.min(3, theme.radius)
            color: overlay.ui.accent
            border.color: Qt.darker(overlay.ui.accent, 1.4)
            Label {
                id: hint
                anchors.centerIn: parent
                textFormat: Text.StyledText
                // What's typed fades, the rest stays to be typed.
                text: "<font color='" + Qt.darker(overlay.ui.accent, 2.2) + "'>" + overlay.typed.toUpperCase() + "</font>"
                      + parent.modelData.label.slice(overlay.typed.length).toUpperCase()
                color: theme.accentForeground
                font.family: "monospace"
                font.pixelSize: 11
                font.weight: Font.Bold
            }
        }
    }
}
