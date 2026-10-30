import QtQuick

Rectangle {
	id: b

	property string icon
	property int size: 36
	property color base: Theme.cardHi
	property color fg: Theme.text
	signal clicked

	implicitWidth: size
	implicitHeight: size
	radius: size / 2
	color: area.containsMouse ? Qt.lighter(base, 1.25) : base
	Behavior on color { ColorAnimation { duration: 120 } }

	Lbl {
		anchors.centerIn: parent
		text: b.icon
		color: b.fg
		font.pixelSize: b.size * 0.45
	}

	MouseArea {
		id: area
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: b.clicked()
	}
}
