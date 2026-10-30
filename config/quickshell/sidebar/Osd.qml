import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
	id: osd

	property bool shown: false
	property string icon: "󰕾"
	property int value: 0
	property string label: ""

	IpcHandler {
		target: "osd"
		function mostrar(icon: string, value: string, label: string): void {
			osd.icon = icon; osd.value = value === "no" ? -1 : parseInt(value) || 0; osd.label = label;
			osd.shown = true;
			hide.restart();
		}
	}

	Timer { id: hide; interval: 1400; onTriggered: osd.shown = false }

	PanelWindow {
		id: w
		property real reveal: osd.shown ? 1 : 0
		Behavior on reveal { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

		visible: reveal > 0.001
		anchors { top: true }
		margins { top: 52 }
		implicitWidth: 300
		implicitHeight: 64
		color: "transparent"
		exclusionMode: ExclusionMode.Ignore
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "quickshell-osd"
		WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
		mask: Region {}   // no se come los clicks

		Rectangle {
			width: parent.width; height: 52
			y: -10 * (1 - w.reveal)
			opacity: w.reveal
			scale: 0.94 + 0.06 * w.reveal
			radius: 26
			color: Theme.card
			border.width: 1
			border.color: Qt.alpha(Theme.primary, 0.35)

			Text {
				id: ic
				anchors { left: parent.left; leftMargin: 18; verticalCenter: parent.verticalCenter }
				text: osd.icon
				color: Theme.primary
				font { family: Theme.font; pixelSize: 22 }
			}
			Column {
				anchors { left: ic.right; leftMargin: 14; right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
				spacing: 6
				Item {
					width: parent.width; height: lbl.height
					Text { id: lbl; text: osd.label; color: Theme.text; font { family: Theme.font; pixelSize: 13; bold: true } }
					Text {
						anchors.right: parent.right
						visible: osd.value >= 0
						text: osd.value + "%"
						color: Theme.sub
						font { family: Theme.font; pixelSize: 12 }
					}
				}
				Rectangle {
					visible: osd.value >= 0
					width: parent.width; height: 6; radius: 3
					color: Theme.cardTop
					Rectangle {
						height: parent.height; radius: 3
						width: parent.width * Math.min(osd.value, 100) / 100
						color: osd.value > 100 ? Theme.error : Theme.primary
						Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
					}
				}
			}
		}
	}
}
