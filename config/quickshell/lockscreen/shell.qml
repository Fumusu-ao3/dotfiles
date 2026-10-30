import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

ShellRoot {
	id: root

	readonly property bool test: Quickshell.env("LOCK_TEST") === "1"
	property string password: ""
	property bool unlocking: false
	property bool failed: false

	function submit(text) {
		if (unlocking || text.length === 0)
			return;
		password = text;
		failed = false;
		unlocking = true;
		pam.start();
	}

	PamContext {
		id: pam

		onResponseRequiredChanged: {
			if (responseRequired && root.unlocking)
				respond(root.password);
		}

		onCompleted: result => {
			root.unlocking = false;
			root.password = "";
			if (result === PamResult.Success) {
				lock.locked = false;
				Qt.quit();
			} else {
				root.failed = true;
			}
		}
	}

	WlSessionLock {
		id: lock
		locked: !root.test

		WlSessionLockSurface {
			color: "#c9b6ec"

			LockView {
				anchors.fill: parent
				shell: root
			}
		}
	}

	LazyLoader {
		active: root.test

		FloatingWindow {
			implicitWidth: 1366
			implicitHeight: 768
			color: "#c9b6ec"

			LockView {
				id: preview
				anchors.fill: parent
				shell: root
			}

			Timer {
				running: !!Quickshell.env("LOCK_SHOT")
				interval: 5000
				onTriggered: preview.grabToImage(r => {
					r.saveToFile(Quickshell.env("LOCK_SHOT"));
					Qt.quit();
				})
			}
		}
	}
}
