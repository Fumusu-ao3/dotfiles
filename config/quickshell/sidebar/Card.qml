import QtQuick
import QtQuick.Layouts

Rectangle {
	id: card

	property string title
	property string icon
	property alias headerExtra: extra.data
	default property alias content: body.data

	Layout.fillWidth: true
	implicitHeight: col.implicitHeight + 28
	radius: 20
	color: Theme.card

	ColumnLayout {
		id: col
		anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
		spacing: 10

		RowLayout {
			visible: card.title !== ""
			Layout.fillWidth: true
			spacing: 8
			Lbl { text: card.icon; color: Theme.primary; font.pixelSize: 15 }
			Lbl { text: card.title; font.pixelSize: 14; font.bold: true; Layout.fillWidth: true }
			Row { id: extra; spacing: 6 }
		}

		ColumnLayout {
			id: body
			Layout.fillWidth: true
			spacing: 8
		}
	}
}
