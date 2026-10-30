import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
	id: root

	property bool open: false

	IpcHandler {
		target: "sidebar"
		function toggle(): void { root.open = !root.open; }
		function open(): void { root.open = true; }
		function close(): void { root.open = false; }
	}

	Osd {}
	Fondos {}

	PanelWindow {
		id: win

		property real reveal: root.open ? 1 : 0
		Behavior on reveal { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

		visible: reveal > 0.001
		anchors { left: true; top: true; bottom: true }
		margins { top: 50; bottom: 10; left: 10 }
		implicitWidth: 380
		color: "transparent"
		exclusionMode: ExclusionMode.Ignore
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "quickshell-sidebar"
		WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

		Sidebar {
			id: panel
			width: parent.width
			height: parent.height
			x: -(width + 12) * (1 - win.reveal)
			opacity: win.reveal
			shell: root
			focus: true
			Keys.onEscapePressed: root.open = false
		}
	}
}
