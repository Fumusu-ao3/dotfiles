import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

Card {
	id: card

	property bool active
	readonly property var players: Mpris.players.values
	readonly property MprisPlayer player: players.find(p => p.isPlaying) ?? players[0] ?? null

	title: "Música"
	icon: "󰎆"

	function fmt(s) {
		if (!isFinite(s) || s < 0) return "0:00";
		const m = Math.floor(s / 60), r = Math.floor(s % 60);
		return m + ":" + (r < 10 ? "0" : "") + r;
	}

	Timer {
		interval: 1000
		repeat: true
		running: card.active && card.player !== null && card.player.isPlaying
		onTriggered: card.player.positionChanged()
	}

	Lbl {
		visible: card.player === null
		text: "No suena nada ahora."
		color: Theme.sub
	}

	RowLayout {
		visible: card.player !== null
		Layout.fillWidth: true
		spacing: 12

		ClippingRectangle {
			implicitWidth: 84
			implicitHeight: 84
			radius: 14
			color: Theme.cardTop

			Lbl {
				anchors.centerIn: parent
				text: "󰎈"
				font.pixelSize: 32
				color: Theme.sub
				visible: art.status !== Image.Ready
			}
			Image {
				id: art
				anchors.fill: parent
				source: card.player?.trackArtUrl ?? ""
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
				sourceSize.width: 168
				sourceSize.height: 168
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 2
			Lbl {
				Layout.fillWidth: true
				text: card.player?.trackTitle || "Sin título"
				font.pixelSize: 14
				font.bold: true
			}
			Lbl {
				Layout.fillWidth: true
				text: card.player?.trackArtist || card.player?.identity || ""
				color: Theme.sub
			}
			Lbl {
				Layout.fillWidth: true
				text: card.player?.identity ?? ""
				color: Theme.primary
				font.pixelSize: 11
			}
		}
	}

	ColumnLayout {
		visible: card.player !== null && card.player.lengthSupported && card.player.length > 0
		Layout.fillWidth: true
		spacing: 2

		Rectangle {
			Layout.fillWidth: true
			implicitHeight: 6
			radius: 3
			color: Theme.cardTop
			Rectangle {
				width: parent.width * (card.player ? Math.min(1, card.player.position / card.player.length) : 0)
				height: parent.height
				radius: 3
				color: Theme.primary
			}
			MouseArea {
				anchors.fill: parent
				anchors.margins: -6
				cursorShape: Qt.PointingHandCursor
				enabled: card.player?.canSeek ?? false
				onClicked: e => card.player.position = card.player.length * Math.max(0, Math.min(1, (e.x - 6) / (width - 12)))
			}
		}
		RowLayout {
			Layout.fillWidth: true
			Lbl { text: card.fmt(card.player?.position ?? 0); color: Theme.sub; font.pixelSize: 11; Layout.fillWidth: true }
			Lbl { text: card.fmt(card.player?.length ?? 0); color: Theme.sub; font.pixelSize: 11 }
		}
	}

	RowLayout {
		visible: card.player !== null
		Layout.alignment: Qt.AlignHCenter
		spacing: 14
		IconBtn {
			icon: "󰒮"
			enabled: card.player?.canGoPrevious ?? false
			opacity: enabled ? 1 : 0.4
			onClicked: card.player.previous()
		}
		IconBtn {
			icon: card.player?.isPlaying ? "󰏤" : "󰐊"
			size: 46
			base: Theme.primary
			fg: Theme.textOnPrimary
			onClicked: card.player.togglePlaying()
		}
		IconBtn {
			icon: "󰒭"
			enabled: card.player?.canGoNext ?? false
			opacity: enabled ? 1 : 0.4
			onClicked: card.player.next()
		}
	}
}
