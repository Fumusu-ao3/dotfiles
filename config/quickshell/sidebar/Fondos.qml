import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
	id: f

	property bool open: false
	readonly property string script: Quickshell.env("HOME") + "/.local/bin/wallpaper.sh"
	property var todos: []          // [{ruta, nombre, carpeta, mini}]
	property var carpetas: []
	property string carpeta: ""     // "" = todas
	property string actual: ""
	property int rev: 0             // sube cuando terminan las miniaturas nuevas

	readonly property var visibles: {
		const q = buscar.text.trim().toLowerCase();
		return todos.filter(w => (carpeta === "" || w.carpeta === carpeta)
			&& (q === "" || w.nombre.toLowerCase().includes(q)));
	}

	IpcHandler {
		target: "fondos"
		function toggle(): void { f.open ? f.cerrar() : f.abrir(); }
		function abrir(): void { f.abrir(); }
		function cerrar(): void { f.cerrar(); }
	}

	function abrir() {
		buscar.text = "";
		lista.running = true;
		open = true;
	}

	function cerrar() { open = false; }

	function url(ruta) {
		return "file://" + ruta.split("/").map(encodeURIComponent).join("/");
	}

	function poner(ruta) {
		actual = ruta;
		Quickshell.execDetached([script, "set", ruta]);
	}

	function elegirActual() {
		const i = visibles.findIndex(w => w.ruta === actual);
		grilla.currentIndex = Math.max(i, 0);
		grilla.positionViewAtIndex(grilla.currentIndex, GridView.Center);
	}

	FileView {
		path: Quickshell.env("HOME") + "/.cache/wallpaper/current"
		watchChanges: true
		onFileChanged: reload()
		onLoaded: f.actual = text().trim()
	}

	Process {
		id: lista
		command: [f.script, "lista"]
		stdout: StdioCollector {
			onStreamFinished: {
				const base = Quickshell.env("HOME") + "/wallpapers/";
				const out = [], dirs = [];
				for (const l of text.split("\n")) {
					const [ruta, mini] = l.split("\t");
					if (!mini) continue;
					const rel = ruta.startsWith(base) ? ruta.slice(base.length) : ruta;
					const i = rel.lastIndexOf("/");
					const carpeta = i < 0 ? "" : rel.slice(0, i);
					if (!dirs.includes(carpeta)) dirs.push(carpeta);
					out.push({ ruta, mini, carpeta, nombre: rel.slice(i + 1).replace(/\.[^.]+$/, "") });
				}
				f.todos = out;
				f.carpetas = dirs;
				if (f.carpeta === "") {
					const w = out.find(w => w.ruta === f.actual);
					if (w) f.carpeta = w.carpeta;
				}
				Qt.callLater(f.elegirActual);
				miniaturas.running = true;
			}
		}
	}

	Process {
		id: miniaturas
		command: [f.script, "miniaturas"]
		onExited: f.rev++
	}

	function moverCarpeta(paso) {
		const op = [""].concat(carpetas);
		carpeta = op[(op.indexOf(carpeta) + paso + op.length) % op.length];
		Qt.callLater(elegirActual);
	}

	PanelWindow {
		id: win

		property real reveal: f.open ? 1 : 0
		Behavior on reveal { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

		visible: reveal > 0.001
		anchors { bottom: true; left: true; right: true }
		margins { bottom: 12; left: 40; right: 40 }
		implicitHeight: 470
		color: "transparent"
		exclusionMode: ExclusionMode.Ignore
		WlrLayershell.layer: WlrLayer.Overlay
		WlrLayershell.namespace: "quickshell-fondos"
		WlrLayershell.keyboardFocus: f.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

		Rectangle {
			id: panel
			width: parent.width
			height: parent.height
			y: 30 * (1 - win.reveal)
			opacity: win.reveal
			radius: 24
			color: Theme.bg
			border.color: Theme.outline
			border.width: 1

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 16
				spacing: 12

				RowLayout {
					Layout.fillWidth: true
					spacing: 10

					Lbl { text: "󰸉"; color: Theme.primary; font.pixelSize: 20 }
					Lbl { text: "Fondos"; font.pixelSize: 16; font.bold: true }
					Lbl { text: f.visibles.length; color: Theme.sub; font.pixelSize: 12 }
					Item { Layout.fillWidth: true }

					Rectangle {
						implicitWidth: 260
						implicitHeight: 36
						radius: 18
						color: Theme.cardHi
						border.width: buscar.text !== "" ? 1 : 0
						border.color: Theme.primary

						Lbl {
							id: lupa
							anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
							text: "󰍉"
							color: Theme.sub
						}
						TextInput {
							id: buscar
							anchors { left: lupa.right; leftMargin: 8; right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
							focus: true
							color: Theme.text
							selectionColor: Theme.primaryCont
							font { family: Theme.font; pixelSize: 13 }
							clip: true
							onTextChanged: Qt.callLater(() => { grilla.currentIndex = 0; grilla.positionViewAtBeginning(); })

							Lbl {
								visible: buscar.text === ""
								text: "Buscar..."
								color: Theme.sub
								opacity: 0.6
							}

							Keys.onPressed: e => {
								const cols = Math.max(1, Math.floor(grilla.width / grilla.cellWidth));
								const n = f.visibles.length;
								let i = grilla.currentIndex;
								switch (e.key) {
								case Qt.Key_Escape: f.cerrar(); break;
								case Qt.Key_Right: i = Math.min(i + 1, n - 1); break;
								case Qt.Key_Left: i = Math.max(i - 1, 0); break;
								case Qt.Key_Down: i = Math.min(i + cols, n - 1); break;
								case Qt.Key_Up: i = Math.max(i - cols, 0); break;
								case Qt.Key_PageDown: i = Math.min(i + cols * 3, n - 1); break;
								case Qt.Key_PageUp: i = Math.max(i - cols * 3, 0); break;
								case Qt.Key_Tab: f.moverCarpeta(1); break;
								case Qt.Key_Backtab: f.moverCarpeta(-1); break;
								case Qt.Key_Return:
								case Qt.Key_Enter:
									if (n > 0) { f.poner(f.visibles[i].ruta); f.cerrar(); }
									break;
								default: return;
								}
								e.accepted = true;
								grilla.currentIndex = i;
							}
						}
					}

					IconBtn {
						icon: "󰒝"
						onClicked: {
							const v = f.visibles.filter(w => w.ruta !== f.actual);
							if (v.length === 0) return;
							const w = v[Math.floor(Math.random() * v.length)];
							f.poner(w.ruta);
							grilla.currentIndex = f.visibles.indexOf(w);
							grilla.positionViewAtIndex(grilla.currentIndex, GridView.Contain);
						}
					}
					IconBtn {
						icon: "󰉋"
						onClicked: { Quickshell.execDetached(["xdg-open", Quickshell.env("HOME") + "/wallpapers"]); f.cerrar(); }
					}
					IconBtn { icon: "󰅖"; onClicked: f.cerrar() }
				}

				Flickable {
					Layout.fillWidth: true
					implicitHeight: 32
					contentWidth: chips.width
					clip: true
					boundsBehavior: Flickable.StopAtBounds

					Row {
						id: chips
						spacing: 8
						Repeater {
							model: [""].concat(f.carpetas)
							Rectangle {
								required property string modelData
								readonly property bool sel: f.carpeta === modelData
								width: chip.implicitWidth + 28
								height: 32
								radius: 16
								color: sel ? Theme.primary : (chipArea.containsMouse ? Theme.cardTop : Theme.cardHi)
								Behavior on color { ColorAnimation { duration: 120 } }
								Lbl {
									id: chip
									anchors.centerIn: parent
									text: (parent.modelData === "" ? "Todos" : parent.modelData) + "  "
										+ (parent.modelData === "" ? f.todos.length
											: f.todos.filter(w => w.carpeta === parent.modelData).length)
									color: parent.sel ? Theme.textOnPrimary : Theme.text
									font.bold: parent.sel
								}
								MouseArea {
									id: chipArea
									anchors.fill: parent
									hoverEnabled: true
									cursorShape: Qt.PointingHandCursor
									onClicked: { f.carpeta = parent.modelData; Qt.callLater(f.elegirActual); }
								}
							}
						}
					}
				}

				GridView {
					id: grilla
					Layout.fillWidth: true
					Layout.fillHeight: true
					clip: true
					model: f.visibles
					cellWidth: width / Math.max(1, Math.floor(width / 190))
					cellHeight: cellWidth * 9 / 16 + 10
					cacheBuffer: cellHeight * 2
					boundsBehavior: Flickable.StopAtBounds
					highlightFollowsCurrentItem: false
					keyNavigationEnabled: false

					delegate: Item {
						id: celda
						required property var modelData
						required property int index
						readonly property bool esActual: modelData.ruta === f.actual
						readonly property bool sel: GridView.isCurrentItem
						width: grilla.cellWidth
						height: grilla.cellHeight

						ClippingRectangle {
							id: marco
							anchors.fill: parent
							anchors.margins: 5
							radius: 14
							color: Theme.cardHi
							scale: area.containsMouse ? 1.04 : 1
							Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

							Lbl {
								anchors.centerIn: parent
								visible: img.status !== Image.Ready
								text: "󰋩"
								color: Theme.sub
								font.pixelSize: 22
							}

							Image {
								id: img
								anchors.fill: parent
								source: f.url(celda.modelData.mini)
								sourceSize: Qt.size(384, 216)
								fillMode: Image.PreserveAspectCrop
								asynchronous: true
								opacity: status === Image.Ready ? 1 : 0
								Behavior on opacity { NumberAnimation { duration: 180 } }

								Connections {
									target: f
									function onRevChanged() {
										if (img.status === Image.Error) {
											img.source = "";
											img.source = f.url(celda.modelData.mini);
										}
									}
								}
							}

							Rectangle {
								anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
								height: 28
								visible: area.containsMouse || celda.sel
								gradient: Gradient {
									GradientStop { position: 0; color: "transparent" }
									GradientStop { position: 1; color: Qt.alpha("black", 0.7) }
								}
								Lbl {
									anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 8; bottomMargin: 5 }
									text: celda.modelData.nombre
									color: "white"
									font.pixelSize: 11
								}
							}

							Rectangle {
								visible: celda.esActual
								anchors { top: parent.top; right: parent.right; margins: 7 }
								width: 24; height: 24; radius: 12
								color: Theme.primary
								Lbl { anchors.centerIn: parent; text: "󰄬"; color: Theme.textOnPrimary; font.pixelSize: 14 }
							}
						}

						Rectangle {
							anchors.fill: marco
							scale: marco.scale
							radius: 14
							color: "transparent"
							border.width: celda.esActual ? 3 : (celda.sel ? 2 : 0)
							border.color: celda.esActual ? Theme.primary : Theme.secondary
						}

						MouseArea {
							id: area
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onClicked: { grilla.currentIndex = celda.index; f.poner(celda.modelData.ruta); }
							onDoubleClicked: f.cerrar()
						}
					}

					onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)

					Lbl {
						anchors.centerIn: parent
						visible: f.visibles.length === 0 && f.todos.length > 0
						text: "Nada con \"" + buscar.text + "\""
						color: Theme.sub
					}
				}
			}
		}
	}
}
