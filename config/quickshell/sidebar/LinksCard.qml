import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Io

Card {
	id: card

	property var data: ({ strawpage: null, redes: [] })

	title: "Redes"
	icon: "󰖟"

	function abrir(url) { Quickshell.execDetached(["xdg-open", url]); }

	FileView {
		path: Quickshell.shellDir + "/links.json"
		watchChanges: true
		onFileChanged: reload()
		onLoaded: {
			try { card.data = JSON.parse(text()); } catch (e) {}
		}
	}

	headerExtra: IconBtn {
		icon: "󰏫"
		size: 26
		onClicked: Quickshell.execDetached(["xdg-open", Quickshell.shellDir + "/links.json"])
	}

	Rectangle {
		visible: !!card.data.strawpage
		Layout.fillWidth: true
		implicitHeight: 54
		radius: 16
		color: straw.containsMouse ? Qt.lighter(Theme.primaryCont, 1.2) : Theme.primaryCont
		Behavior on color { ColorAnimation { duration: 120 } }

		RowLayout {
			anchors.fill: parent
			anchors.margins: 12
			spacing: 10
			Lbl { text: "🍓"; font.pixelSize: 22 }
			ColumnLayout {
				Layout.fillWidth: true
				spacing: 0
				Lbl {
					Layout.fillWidth: true
					text: card.data.strawpage?.titulo ?? "Mi página"
					color: Theme.textOnPrimaryCont
					font.bold: true
				}
				Lbl {
					Layout.fillWidth: true
					text: (card.data.strawpage?.url ?? "").replace(/^https?:\/\//, "")
					color: Theme.textOnPrimaryCont
					opacity: 0.75
					font.pixelSize: 11
				}
			}
			Lbl { text: "󰁔"; color: Theme.textOnPrimaryCont; font.pixelSize: 18 }
		}
		MouseArea {
			id: straw
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: card.abrir(card.data.strawpage.url)
		}
	}

	GridLayout {
		Layout.fillWidth: true
		columns: 3
		rowSpacing: 8
		columnSpacing: 8

		Repeater {
			model: card.data.redes ?? []
			Rectangle {
				required property var modelData
				Layout.fillWidth: true
				implicitHeight: 58
				radius: 14
				color: ma.containsMouse ? Theme.cardTop : Theme.cardHi
				Behavior on color { ColorAnimation { duration: 120 } }

				Column {
					anchors.centerIn: parent
					spacing: 2
					Lbl {
						visible: !modelData.img
						anchors.horizontalCenter: parent.horizontalCenter
						text: modelData.icon ?? "󰌹"
						color: Theme.primary
						font.pixelSize: 20
					}
					Rectangle {
						visible: !!modelData.img
						anchors.horizontalCenter: parent.horizontalCenter
						width: 20
						height: 20
						color: Theme.primary
						layer.enabled: true
						layer.effect: MultiEffect {
							maskEnabled: true
							maskSource: mascara
						}
						Image {
							id: mascara
							anchors.fill: parent
							visible: false
							layer.enabled: true
							source: modelData.img ? Quickshell.shellDir + "/iconos/" + modelData.img : ""
							sourceSize.width: 40
							sourceSize.height: 40
						}
					}
					Lbl {
						anchors.horizontalCenter: parent.horizontalCenter
						text: modelData.nombre ?? ""
						font.pixelSize: 11
					}
				}
				MouseArea {
					id: ma
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: card.abrir(modelData.url)
				}
			}
		}
	}
}
