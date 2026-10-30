pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: t

	property var c: ({})
	readonly property string font: "Nunito"
	readonly property color bg: c.surface ?? "#14140c"
	readonly property color card: c.surface_container ?? "#212018"
	readonly property color cardHi: c.surface_container_high ?? "#2b2a22"
	readonly property color cardTop: c.surface_container_highest ?? "#36352c"
	readonly property color text: c.on_surface ?? "#e6e2d5"
	readonly property color sub: c.on_surface_variant ?? "#cac7b5"
	readonly property color outline: c.outline_variant ?? "#49473a"
	readonly property color primary: c.primary ?? "#ceca75"
	readonly property color textOnPrimary: c.on_primary ?? "#343200"
	readonly property color primaryCont: c.primary_container ?? "#4b4900"
	readonly property color textOnPrimaryCont: c.on_primary_container ?? "#ebe68e"
	readonly property color secondary: c.secondary ?? "#cbc8a2"
	readonly property color tertiary: c.tertiary ?? "#a6d0b9"
	readonly property color tertiaryCont: c.tertiary_container ?? "#274e3e"
	readonly property color textOnTertiaryCont: c.on_tertiary_container ?? "#c1ecd4"
	readonly property color error: c.error ?? "#ffb4ab"

	FileView {
		path: Quickshell.shellDir + "/colors.json"
		watchChanges: true
		onFileChanged: reload()
		onLoaded: {
			try { t.c = JSON.parse(text()); } catch (e) {}
		}
	}
}
