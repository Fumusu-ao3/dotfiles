import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
	id: side

	required property var shell
	readonly property bool active: shell.open

	radius: 24
	color: Theme.bg
	border.color: Theme.outline
	border.width: 1

	property string clima: ""
	Process {
		id: climaProc
		command: ["curl", "-s", "-m", "8", "wttr.in/?format=%c|%t|%C|%l&lang=es"]
		stdout: StdioCollector {
			onStreamFinished: {
				const p = text.trim().split("|");
				if (p.length >= 3 && !text.includes("<"))
					side.clima = p[0].trim() + "  " + p[1].replace("+", "") + " · " + p[2];
			}
		}
	}
	Timer {
		interval: 30 * 60 * 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: climaProc.running = true
	}

	SystemClock { id: clock; precision: SystemClock.Minutes }

	Flickable {
		id: flick
		anchors.fill: parent
		anchors.margins: 12
		contentHeight: column.implicitHeight
		clip: true
		boundsBehavior: Flickable.StopAtBounds

		ColumnLayout {
			id: column
			width: flick.width
			spacing: 12

			Rectangle {
				Layout.fillWidth: true
				implicitHeight: head.implicitHeight + 28
				radius: 20
				gradient: Gradient {
					orientation: Gradient.Horizontal
					GradientStop { position: 0; color: Theme.primaryCont }
					GradientStop { position: 1; color: Theme.tertiaryCont }
				}

				ColumnLayout {
					id: head
					anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
					spacing: 2

					RowLayout {
						Layout.fillWidth: true
						Lbl {
							text: Qt.formatTime(clock.date, "HH:mm")
							font.pixelSize: 42
							font.bold: true
							color: Theme.textOnPrimaryCont
						}
						Item { Layout.fillWidth: true }
						IconBtn {
							icon: "󰅖"
							size: 30
							base: Qt.rgba(0, 0, 0, 0.18)
							fg: Theme.textOnPrimaryCont
							onClicked: side.shell.open = false
						}
					}
					Lbl {
						Layout.fillWidth: true
						text: {
							const s = clock.date.toLocaleDateString(Qt.locale("es_AR"), "dddd d 'de' MMMM");
							return s.charAt(0).toUpperCase() + s.slice(1);
						}
						color: Theme.textOnPrimaryCont
						font.pixelSize: 14
					}
					Lbl {
						Layout.fillWidth: true
						text: {
							const h = clock.date.getHours();
							const saludo = h < 6 ? "Buenas noches" : h < 13 ? "Buen día" : h < 20 ? "Buenas tardes" : "Buenas noches";
							return saludo + ", Fumusu ✿";
						}
						color: Theme.textOnPrimaryCont
						opacity: 0.85
						font.pixelSize: 12
					}
					Lbl {
						visible: side.clima !== ""
						Layout.fillWidth: true
						Layout.topMargin: 4
						text: side.clima
						color: Theme.textOnPrimaryCont
						font.pixelSize: 12
					}
				}
			}

			MusicCard { active: side.active }
			LinksCard {}
			GalleryCard { active: side.active }
			SystemCard { active: side.active }
			NotesCard {}

			RowLayout {
				Layout.fillWidth: true
				Layout.bottomMargin: 2
				spacing: 8
				Item { Layout.fillWidth: true }
				Repeater {
					model: [
						{ icon: "󰌾", cmd: ["qs", "-c", "lockscreen"] },
						{ icon: "󰸉", cmd: [Quickshell.env("HOME") + "/.local/bin/wallpaper.sh", "gui"] },
						{ icon: "󰒓", cmd: [Quickshell.env("HOME") + "/.local/bin/ajustes-rapidos"] },
						{ icon: "󰉋", cmd: ["thunar"] },
						{ icon: "⏻", cmd: [Quickshell.env("HOME") + "/.local/bin/powermenu.sh"] }
					]
					IconBtn {
						required property var modelData
						icon: modelData.icon
						size: 40
						onClicked: {
							side.shell.open = false;
							Quickshell.execDetached(modelData.cmd);
						}
					}
				}
				Item { Layout.fillWidth: true }
			}
		}
	}
}
