import QtQuick
import QtQuick.Layouts

ColumnLayout {
	id: bar

	property string label
	property string value
	property real fraction: 0
	property color fill: Theme.primary

	Layout.fillWidth: true
	spacing: 4

	RowLayout {
		Layout.fillWidth: true
		Lbl { text: bar.label; color: Theme.sub; font.pixelSize: 12; Layout.fillWidth: true }
		Lbl { text: bar.value; font.pixelSize: 12; font.bold: true }
	}
	Rectangle {
		Layout.fillWidth: true
		implicitHeight: 6
		radius: 3
		color: Theme.cardTop
		Rectangle {
			width: parent.width * Math.max(0, Math.min(1, bar.fraction))
			height: parent.height
			radius: 3
			color: bar.fill
			Behavior on width { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
		}
	}
}
