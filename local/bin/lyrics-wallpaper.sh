#!/usr/bin/env bash
DIR="$HOME/.config/lyrics-wallpaper"
LYRICS="$DIR/letra.txt"
TITLE_FILE="$DIR/titulo.txt"
OUTDIR="$HOME/.cache/lyrics-wallpaper"
BASE="$OUTDIR/base"
mkdir -p "$DIR" "$OUTDIR"

current="$(cat "$HOME/.cache/wallpaper/current" 2>/dev/null)"
if [ -n "$current" ] && [[ "$current" != "$OUTDIR"/* ]]; then
    echo "$current" > "$BASE"
fi

case "$1" in
    clip)
        wl-paste --no-newline > "$LYRICS" || { notify-send "Letra" "No hay nada copiado"; exit 1; } ;;
    edit)
        [ -f "$TITLE_FILE" ] || echo "Lord Verity" > "$TITLE_FILE"
        touch "$LYRICS"
        xdg-open "$LYRICS"; exit ;;
    off)
        ~/.local/bin/wallpaper.sh set "$(cat "$BASE")"; exit ;;
esac

[ -s "$LYRICS" ] || { notify-send "Letra" "Copiá la letra y usá: lyrics-wallpaper.sh clip"; exit 1; }
[ -f "$TITLE_FILE" ] || echo "Lord Verity" > "$TITLE_FILE"

res="$(awww query 2>/dev/null | grep -o '[0-9]*x[0-9]*' | head -n1)"
out="$OUTDIR/letra-$(date +%s).png"
rm -f "$OUTDIR"/letra-*.png
python3 "$HOME/.local/bin/lyrics-wallpaper.py" "$LYRICS" "$(cat "$BASE")" "$out" "${res:-1366x768}" "$(cat "$TITLE_FILE")" \
    && ~/.local/bin/wallpaper.sh set "$out"
