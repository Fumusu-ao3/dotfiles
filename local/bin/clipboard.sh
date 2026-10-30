#!/usr/bin/env bash
command -v cliphist >/dev/null || { notify-send "Portapapeles" "Falta instalar cliphist"; exit 1; }
sel="$(cliphist list | fuzzel --dmenu --prompt '  ' --width 60)" || exit 0
cliphist decode <<<"$sel" | wl-copy
