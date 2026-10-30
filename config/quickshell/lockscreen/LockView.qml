import QtQuick
import Quickshell

Item {
	id: view

	required property var shell

	readonly property color ink: "#5b4a86"
	readonly property color inkSoft: "#8a78b5"
	readonly property color pink: "#ff9ecf"
	readonly property color cyan: "#8fe3ff"
	readonly property color cream: "#fffaf3"
	readonly property real horizon: 0.70
	readonly property string user: Quickshell.env("USER") || "soñador"

	property date now: new Date()

	Timer {
		interval: 1000
		running: true
		repeat: true
		onTriggered: view.now = new Date()
	}

	Rectangle {
		anchors.fill: parent
		gradient: Gradient {
			GradientStop { position: 0.00; color: "#a99be6" }
			GradientStop { position: 0.38; color: "#d9b4ea" }
			GradientStop { position: 0.62; color: "#ffc9df" }
			GradientStop { position: view.horizon; color: "#fff0e6" }
			GradientStop { position: 1.00; color: "#fff0e6" }
		}
	}

	Rectangle {
		width: view.height * 0.55
		height: width
		radius: width / 2
		x: -width * 0.25
		y: -height * 0.3
		color: "#fff6fb"
		opacity: 0.35
	}
	Rectangle {
		width: view.height * 0.32
		height: width
		radius: width / 2
		x: view.height * 0.0
		y: -height * 0.05
		color: "#fffdf7"
		opacity: 0.45
	}

	Item {
		id: rings
		width: 1
		height: 1
		x: view.width * 0.76
		y: view.height * 0.5

		Repeater {
			model: 5
			Rectangle {
				required property int index
				readonly property real size: view.height * (0.62 + index * 0.34)
				width: size
				height: size
				radius: size / 2
				x: -size / 2
				y: -size / 2
				color: "transparent"
				border.width: 1.5
				border.color: "#ffffff"
				opacity: 0.42 - index * 0.07
			}
		}

		SequentialAnimation on scale {
			loops: Animation.Infinite
			NumberAnimation { from: 1.0; to: 1.035; duration: 4200; easing.type: Easing.InOutSine }
			NumberAnimation { from: 1.035; to: 1.0; duration: 4200; easing.type: Easing.InOutSine }
		}
	}

	Canvas {
		id: clouds
		width: view.width * 2
		height: view.height * view.horizon
		opacity: 0.85

		onPaint: {
			const ctx = getContext("2d");
			ctx.reset();
			const rand = (seed => () => (seed = (seed * 16807) % 2147483647) / 2147483647)(7);
			const puff = (cx, cy, r) => {
				const g = ctx.createRadialGradient(cx, cy, 0, cx, cy, r);
				g.addColorStop(0, "rgba(255,255,255,0.9)");
				g.addColorStop(0.55, "rgba(255,250,253,0.55)");
				g.addColorStop(1, "rgba(255,245,252,0)");
				ctx.fillStyle = g;
				ctx.beginPath();
				ctx.arc(cx, cy, r, 0, Math.PI * 2);
				ctx.fill();
			};
			const half = width / 2;
			for (let i = 0; i < 9; i++) {
				const cx = rand() * half;
				const cy = height * (0.18 + rand() * 0.62);
				const size = view.height * (0.06 + rand() * 0.07);
				for (let k = 0; k < 7; k++) {
					const ox = (rand() - 0.5) * size * 3.2;
					const oy = (rand() - 0.5) * size * 0.8;
					const r = size * (0.7 + rand() * 0.6);
					puff(cx + ox, cy + oy, r);
					puff(cx + ox + half, cy + oy, r);
				}
			}
		}
		onWidthChanged: requestPaint()
		onHeightChanged: requestPaint()

		NumberAnimation on x {
			from: 0
			to: -view.width
			duration: 240000
			loops: Animation.Infinite
		}
	}

	Canvas {
		id: floor
		y: view.height * view.horizon
		width: view.width
		height: view.height - y

		onPaint: {
			const ctx = getContext("2d");
			ctx.reset();
			const w = width, h = height, cx = w * 0.5;
			const rows = 40, cols = 22;
			const z0 = 1.6;
			const rowY = i => h * z0 / (z0 + i);
			for (let i = 0; i < rows; i++) {
				const y0 = rowY(i + 1), y1 = rowY(i);
				const s0 = 0.08 + 0.92 * (y0 / h), s1 = 0.08 + 0.92 * (y1 / h);
				for (let j = -cols; j < cols; j++) {
					if ((i + j) % 2 !== 0)
						continue;
					const u0 = j / cols * w * 2.2, u1 = (j + 1) / cols * w * 2.2;
					ctx.beginPath();
					ctx.moveTo(cx + u0 * s0, y0);
					ctx.lineTo(cx + u1 * s0, y0);
					ctx.lineTo(cx + u1 * s1, y1);
					ctx.lineTo(cx + u0 * s1, y1);
					ctx.closePath();
					ctx.fillStyle = "rgba(255,158,207,0.55)";
					ctx.fill();
				}
			}
			const fog = ctx.createLinearGradient(0, 0, 0, h * 0.6);
			fog.addColorStop(0, "rgba(255,240,230,1)");
			fog.addColorStop(1, "rgba(255,240,230,0)");
			ctx.fillStyle = fog;
			ctx.fillRect(0, 0, w, h * 0.6);
		}
		onWidthChanged: requestPaint()
		onHeightChanged: requestPaint()
	}

	Repeater {
		model: 22
		Text {
			required property int index
			readonly property real seed: Math.abs(Math.sin(index * 12.9898) * 43758.5453) % 1
			readonly property real seed2: Math.abs(Math.sin(index * 78.233) * 12345.678) % 1
			x: seed * view.width
			y: seed2 * view.height * view.horizon
			text: index % 3 === 0 ? "✦" : "·"
			color: "#ffffff"
			font.pixelSize: index % 3 === 0 ? 10 + seed2 * 12 : 18
			opacity: 0

			SequentialAnimation on opacity {
				loops: Animation.Infinite
				PauseAnimation { duration: 400 + (index * 733) % 4000 }
				NumberAnimation { to: 0.9; duration: 1800; easing.type: Easing.InOutSine }
				NumberAnimation { to: 0.1; duration: 2400; easing.type: Easing.InOutSine }
			}
		}
	}

	Column {
		anchors.left: parent.left
		anchors.leftMargin: view.width * 0.07
		anchors.verticalCenter: parent.verticalCenter
		anchors.verticalCenterOffset: -view.height * 0.04
		spacing: 6

		Text {
			readonly property int h: view.now.getHours()
			text: h < 6 ? "todavía es de noche," : h < 12 ? "buen día," : h < 20 ? "buenas tardes," : "buenas noches,"
			color: view.inkSoft
			font.family: "Noto Serif"
			font.italic: true
			font.pixelSize: view.height * 0.032
		}

		Text {
			text: view.user.toLowerCase()
			color: view.ink
			font.family: "Inter Display"
			font.weight: Font.Black
			font.pixelSize: view.height * 0.052
		}

		Item {
			width: clock.implicitWidth
			height: clock.implicitHeight * 0.92

			Repeater {
				model: [{ c: view.cyan, d: -3 }, { c: view.pink, d: 3 }]
				Text {
					required property var modelData
					x: modelData.d
					text: clock.text
					font: clock.font
					color: modelData.c
					opacity: 0.85
				}
			}

			Text {
				id: clock
				text: Qt.formatTime(view.now, "HH:mm")
				color: view.cream
				font.family: "Inter Display"
				font.weight: Font.Black
				font.pixelSize: view.height * 0.21
			}
		}

		Text {
			text: view.now.toLocaleDateString(Qt.locale("es_AR"), "dddd d 'de' MMMM").toUpperCase()
			color: view.ink
			opacity: 0.75
			font.family: "Inter"
			font.weight: Font.Bold
			font.letterSpacing: 4
			font.pixelSize: view.height * 0.016
		}
	}

	Item {
		id: card
		width: Math.max(300, view.height * 0.42)
		height: cardBody.implicitHeight + 40
		x: view.width * 0.76 - width / 2
		anchors.verticalCenter: parent.verticalCenter

		Rectangle {
			anchors.fill: parent
			anchors.leftMargin: 8
			anchors.topMargin: 8
			anchors.rightMargin: -8
			anchors.bottomMargin: -8
			radius: 26
			color: view.pink
			opacity: 0.55
		}

		Rectangle {
			anchors.fill: parent
			radius: 26
			color: "#b3fffaff"
			border.width: 1.5
			border.color: "#ffffff"
		}

		Column {
			id: cardBody
			x: 20
			y: 20
			width: card.width - 40
			spacing: 14

			Row {
				spacing: 14

				Rectangle {
					id: avatar
					width: 58
					height: 58
					radius: 29
					gradient: Gradient {
						GradientStop { position: 0; color: "#b9e6ff" }
						GradientStop { position: 1; color: "#ffc4e1" }
					}
					border.width: 2
					border.color: "#ffffff"

					Image {
						id: face
						anchors.fill: parent
						anchors.margins: 2
						source: "file://" + Quickshell.env("HOME") + "/.face"
						fillMode: Image.PreserveAspectCrop
						visible: status === Image.Ready
						layer.enabled: false
					}
					Text {
						anchors.centerIn: parent
						visible: face.status !== Image.Ready
						text: "☁"
						color: "#ffffff"
						font.pixelSize: 30
					}
				}

				Column {
					anchors.verticalCenter: avatar.verticalCenter
					spacing: 2
					Text {
						text: view.user.toLowerCase()
						color: view.ink
						font.family: "Inter Display"
						font.weight: Font.ExtraBold
						font.pixelSize: 20
					}
					Text {
						text: "estás a salvo acá"
						color: view.inkSoft
						font.family: "Noto Serif"
						font.italic: true
						font.pixelSize: 13
					}
				}
			}

			Text {
				text: "CONTRASEÑA"
				color: view.inkSoft
				font.family: "Inter"
				font.weight: Font.Bold
				font.letterSpacing: 2
				font.pixelSize: 10
			}

			Rectangle {
				id: field
				width: parent.width
				height: 46
				radius: 14
				color: "#ccffffff"
				border.width: 1.5
				border.color: view.shell.failed ? "#ff7aa8" : input.activeFocus ? view.pink : "#e6dcf5"

				TextInput {
					id: input
					anchors.left: parent.left
					anchors.right: showBtn.left
					anchors.leftMargin: 14
					anchors.rightMargin: 8
					anchors.verticalCenter: parent.verticalCenter
					focus: true
					enabled: !view.shell.unlocking
					echoMode: showBtn.shown ? TextInput.Normal : TextInput.Password
					passwordCharacter: "✦"
					color: view.ink
					selectionColor: view.pink
					font.family: "Inter"
					font.pixelSize: 17
					font.letterSpacing: 3
					clip: true

					onAccepted: view.shell.submit(text)
					onTextChanged: if (text.length > 0) view.shell.failed = false
					Keys.onEscapePressed: text = ""

					Component.onCompleted: forceActiveFocus()
				}

				Text {
					anchors.left: input.left
					anchors.verticalCenter: parent.verticalCenter
					visible: input.text.length === 0
					text: "escribí para despertar…"
					color: view.inkSoft
					opacity: 0.6
					font.family: "Noto Serif"
					font.italic: true
					font.pixelSize: 14
				}

				Text {
					id: showBtn
					property bool shown: false
					anchors.right: parent.right
					anchors.rightMargin: 14
					anchors.verticalCenter: parent.verticalCenter
					text: shown ? "OCULTAR" : "VER"
					color: view.inkSoft
					font.family: "Inter"
					font.weight: Font.Bold
					font.letterSpacing: 1.5
					font.pixelSize: 10

					MouseArea {
						anchors.fill: parent
						anchors.margins: -8
						cursorShape: Qt.PointingHandCursor
						onClicked: {
							showBtn.shown = !showBtn.shown;
							input.forceActiveFocus();
						}
					}
				}

				SequentialAnimation {
					id: shake
					NumberAnimation { target: field; property: "x"; to: -9; duration: 50 }
					NumberAnimation { target: field; property: "x"; to: 9; duration: 70 }
					NumberAnimation { target: field; property: "x"; to: -6; duration: 70 }
					NumberAnimation { target: field; property: "x"; to: 0; duration: 60 }
				}
				Connections {
					target: view.shell
					function onFailedChanged() {
						if (view.shell.failed) {
							input.text = "";
							shake.restart();
							input.forceActiveFocus();
						}
					}
				}
			}

			Rectangle {
				width: parent.width
				height: 46
				radius: 14
				color: btnArea.containsMouse ? "#ff8cc4" : view.pink
				Behavior on color { ColorAnimation { duration: 150 } }

				Text {
					anchors.centerIn: parent
					text: view.shell.unlocking ? "entrando al sueño…" : "despertar  →"
					color: "#ffffff"
					font.family: "Inter Display"
					font.weight: Font.ExtraBold
					font.pixelSize: 16
				}

				MouseArea {
					id: btnArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					onClicked: view.shell.submit(input.text)
				}
			}

			Text {
				width: parent.width
				horizontalAlignment: Text.AlignHCenter
				text: view.shell.failed ? "esa no era… probá otra vez" : " "
				color: "#e05a92"
				font.family: "Noto Serif"
				font.italic: true
				font.pixelSize: 13
			}
		}
	}

	Text {
		id: whisper
		property int line: 0
		readonly property var lines: [
			"¿te acordás de este lugar?",
			"ya estuviste acá antes",
			"todo está bien",
			"no te despiertes todavía",
			"el cielo siempre fue de este color",
			"alguien dejó la luz prendida para vos"
		]
		anchors.horizontalCenter: parent.horizontalCenter
		anchors.bottom: parent.bottom
		anchors.bottomMargin: view.height * 0.06
		text: lines[line]
		color: view.ink
		font.family: "Noto Serif"
		font.italic: true
		font.pixelSize: view.height * 0.022
		font.letterSpacing: 1
		opacity: 0

		SequentialAnimation {
			running: true
			loops: Animation.Infinite
			NumberAnimation { target: whisper; property: "opacity"; to: 0.7; duration: 2000; easing.type: Easing.InOutSine }
			PauseAnimation { duration: 5000 }
			NumberAnimation { target: whisper; property: "opacity"; to: 0; duration: 2000; easing.type: Easing.InOutSine }
			ScriptAction { script: whisper.line = (whisper.line + 1) % whisper.lines.length }
			PauseAnimation { duration: 800 }
		}
	}
}
