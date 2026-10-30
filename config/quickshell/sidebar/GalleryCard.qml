import QtQuick
import QtQuick.Layouts
import QtMultimedia
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets

Card {
	id: card

	property bool active
	property int index: 0
	property bool sonido: false
	readonly property string carpeta: Quickshell.env("HOME") + "/Imágenes/Barra"
	readonly property int total: files.count
	readonly property string actual: total > 0 ? files.get(Math.min(index, total - 1), "filePath") : ""
	readonly property string tipo: {
		const ext = actual.split(".").pop().toLowerCase();
		if (["mp4", "webm", "mkv", "mov", "m4v"].includes(ext)) return "video";
		if (["gif", "webp", "apng"].includes(ext)) return "anim";
		return "img";
	}

	title: "Galería"
	icon: "󰋩"

	function mover(d) {
		if (total > 0) index = (index + d + total) % total;
	}

	headerExtra: [
		Lbl {
			anchors.verticalCenter: parent.verticalCenter
			text: card.total > 0 ? (card.index + 1) + " / " + card.total : ""
			color: Theme.sub
			font.pixelSize: 11
		},
		IconBtn {
			icon: "󰉋"
			size: 26
			onClicked: Quickshell.execDetached(["thunar", card.carpeta])
		}
	]

	FolderListModel {
		id: files
		folder: "file://" + card.carpeta
		showDirs: false
		sortField: FolderListModel.Name
		caseSensitive: false
		nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.apng", "*.bmp", "*.avif",
			"*.mp4", "*.webm", "*.mkv", "*.mov", "*.m4v"]
		onCountChanged: if (card.index >= count) card.index = 0
	}

	Timer {
		interval: 12000
		repeat: true
		running: card.active && card.total > 1 && !hover.hovered
		onTriggered: card.mover(1)
	}

	Lbl {
		visible: card.total === 0
		Layout.fillWidth: true
		wrapMode: Text.WordWrap
		text: "Poné imágenes, gifs o videos en ~/Imágenes/Barra y aparecen acá."
		color: Theme.sub
	}

	ClippingRectangle {
		visible: card.total > 0
		Layout.fillWidth: true
		implicitHeight: 230
		radius: 16
		color: Theme.cardTop

		HoverHandler { id: hover }

		Loader {
			anchors.fill: parent
			active: card.active && card.actual !== ""
			sourceComponent: card.tipo === "video" ? videoComp : card.tipo === "anim" ? animComp : imgComp
		}

		Component {
			id: imgComp
			Image {
				source: "file://" + card.actual
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				sourceSize.width: 760
			}
		}
		Component {
			id: animComp
			AnimatedImage {
				source: "file://" + card.actual
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				playing: card.active
			}
		}
		Component {
			id: videoComp
			Video {
				source: "file://" + card.actual
				fillMode: VideoOutput.PreserveAspectCrop
				autoPlay: true
				loops: MediaPlayer.Infinite
				muted: !card.sonido
			}
		}

		MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: Quickshell.execDetached(["xdg-open", card.actual])
		}

		Row {
			anchors { right: parent.right; bottom: parent.bottom; margins: 8 }
			spacing: 6
			opacity: hover.hovered ? 1 : 0
			Behavior on opacity { NumberAnimation { duration: 150 } }

			IconBtn {
				visible: card.tipo === "video"
				icon: card.sonido ? "󰕾" : "󰖁"
				size: 30
				base: Qt.rgba(0, 0, 0, 0.55)
				fg: "white"
				onClicked: card.sonido = !card.sonido
			}
			IconBtn { icon: "󰅁"; size: 30; base: Qt.rgba(0, 0, 0, 0.55); fg: "white"; onClicked: card.mover(-1) }
			IconBtn { icon: "󰅂"; size: 30; base: Qt.rgba(0, 0, 0, 0.55); fg: "white"; onClicked: card.mover(1) }
		}
	}

	ListView {
		visible: card.total > 1
		Layout.fillWidth: true
		implicitHeight: 48
		orientation: ListView.Horizontal
		spacing: 6
		clip: true
		model: files
		currentIndex: card.index
		highlightFollowsCurrentItem: true
		highlightMoveDuration: 200

		delegate: ClippingRectangle {
			id: thumb
			required property int index
			required property string filePath
			required property string fileSuffix
			readonly property bool esVideo: ["mp4", "webm", "mkv", "mov", "m4v"].includes(fileSuffix.toLowerCase())

			width: 48
			height: 48
			radius: 10
			color: Theme.cardTop
			border.width: index === card.index ? 2 : 0
			border.color: Theme.primary

			Image {
				anchors.fill: parent
				visible: !thumb.esVideo
				source: thumb.esVideo ? "" : "file://" + thumb.filePath
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				sourceSize.width: 96
				sourceSize.height: 96
			}
			Lbl {
				anchors.centerIn: parent
				visible: thumb.esVideo
				text: "󰕧"
				color: Theme.primary
				font.pixelSize: 20
			}
			MouseArea {
				anchors.fill: parent
				cursorShape: Qt.PointingHandCursor
				onClicked: card.index = thumb.index
			}
		}
	}
}
