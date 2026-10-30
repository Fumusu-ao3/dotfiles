import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Card {
	id: card

	property bool cargada: false

	title: "Nota rápida"
	icon: "󰠮"

	FileView {
		id: file
		path: Quickshell.shellDir + "/nota.txt"
		onLoaded: {
			if (!card.cargada) {
				editor.text = text();
				card.cargada = true;
			}
		}
	}
	Timer {
		id: guardar
		interval: 800
		onTriggered: file.setText(editor.text)
	}

	Rectangle {
		Layout.fillWidth: true
		implicitHeight: Math.max(80, editor.contentHeight + 20)
		radius: 12
		color: Theme.cardHi
		border.width: editor.activeFocus ? 1 : 0
		border.color: Theme.primary

		TextEdit {
			id: editor
			anchors.fill: parent
			anchors.margins: 10
			wrapMode: TextEdit.Wrap
			font.family: Theme.font
			font.pixelSize: 13
			color: Theme.text
			selectionColor: Theme.primary
			selectedTextColor: Theme.textOnPrimary
			onTextChanged: if (card.cargada) guardar.restart()

			Lbl {
				visible: editor.text === "" && !editor.activeFocus
				text: "Escribí algo para acordarte…"
				color: Theme.sub
			}
		}
	}
}
