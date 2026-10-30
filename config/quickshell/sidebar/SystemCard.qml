import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Card {
	id: card

	property bool active
	property var d: null

	title: "Sistema"
	icon: "󰍛"

	Process {
		id: proc
		command: [Quickshell.env("HOME") + "/.local/bin/barra-sistema"]
		stdout: StdioCollector {
			onStreamFinished: {
				try { card.d = JSON.parse(text); } catch (e) {}
			}
		}
	}
	Timer {
		interval: 3000
		repeat: true
		running: card.active
		triggeredOnStart: true
		onTriggered: if (!proc.running) proc.running = true
	}

	headerExtra: Lbl {
		anchors.verticalCenter: parent.verticalCenter
		text: card.d ? "󰔟 " + card.d.uptime : ""
		color: Theme.sub
		font.pixelSize: 11
	}

	Bar {
		label: "󰻠  CPU"
		value: (card.d?.cpu ?? 0) + "%"
		fraction: (card.d?.cpu ?? 0) / 100
		fill: fraction > 0.85 ? Theme.error : Theme.primary
	}
	Bar {
		label: "󰘚  RAM"
		value: (card.d?.ramg ?? "") + " GB"
		fraction: (card.d?.ram ?? 0) / 100
		fill: fraction > 0.85 ? Theme.error : Theme.secondary
	}
	Bar {
		label: "󰔏  Temperatura"
		value: (card.d?.temp ?? 0) + "°C"
		fraction: (card.d?.temp ?? 0) / 95
		fill: (card.d?.temp ?? 0) > 80 ? Theme.error : Theme.tertiary
	}
	Bar {
		label: "󰋊  Disco /"
		value: (card.d?.disco ?? 0) + "%"
		fraction: (card.d?.disco ?? 0) / 100
		fill: Theme.secondary
	}
	Bar {
		visible: (card.d?.bat ?? -1) >= 0
		label: (card.d?.estado === "Charging" ? "󰂄" : "󰁹") + "  Batería" +
			(card.d?.estado === "Charging" ? " (cargando)" : card.d?.estado === "Full" ? " (llena)" : "")
		value: (card.d?.bat ?? 0) + "%"
		fraction: (card.d?.bat ?? 0) / 100
		fill: fraction < 0.2 ? Theme.error : Theme.primary
	}
}
