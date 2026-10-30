#!/usr/bin/env bash
WALLDIR="${WALLDIR:-$HOME/wallpapers}"
STATE="$HOME/.cache/wallpaper/current"
THUMBS="$HOME/.cache/wallpaper/thumbs"
mkdir -p "${STATE%/*}"

list() {
    find -L "$WALLDIR" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' \
        -o -iname '*.webp' -o -iname '*.gif' \) | sort
}

miniatura() { local r="${1#"$WALLDIR"/}"; echo "$THUMBS/${r//\//__}.jpg"; }

current() { [ -f "$STATE" ] && cat "$STATE"; }

ensure_daemon() {
    if ! command -v awww >/dev/null; then
        command -v swaybg >/dev/null && return
        notify-send -u critical "Wallpaper" "Falta instalar awww: sudo pacman -S awww"
        exit 1
    fi
    pgrep -x awww-daemon >/dev/null && return
    awww-daemon >/dev/null 2>&1 &
    for _ in $(seq 20); do awww query >/dev/null 2>&1 && return; sleep 0.1; done
}

show() {
    if command -v awww >/dev/null; then
        awww img "$1" --transition-type "$2" --transition-pos 0.5,0.5 \
            --transition-fps 45 --transition-duration 1.2
    else
        pkill -x swaybg
        setsid swaybg -m fill -i "$1" >/dev/null 2>&1 &
    fi
}

apply() {
    echo "$1" > "$STATE"
    ln -sf "$1" "$HOME/.cache/wallpaper/current.img"
    if command -v matugen >/dev/null; then
        matugen image "$1" -m dark -t scheme-tonal-spot --source-color-index 0 -q
        mmsg dispatch reload_config >/dev/null 2>&1
    fi
}

set_wall() {
    local f="$1" transition="${2:-grow}"
    [ -f "$f" ] || { notify-send "Wallpaper" "No existe: $f"; exit 1; }
    ensure_daemon
    show "$f" "$transition" || exit 1
    apply "$f"
    notify-send -a Fondo -u low -t 2500 -i "$f" \
        -h string:x-canonical-private-synchronous:fondo "Fondo nuevo 󰸉" "${f##*/}"
}

step() {
    local cur all idx n
    cur="$(current)"
    mapfile -t all < <(list)
    n=${#all[@]}; [ "$n" -eq 0 ] && exit 1
    idx=-1
    for i in "${!all[@]}"; do [ "${all[$i]}" = "$cur" ] && idx=$i && break; done
    set_wall "${all[$(( (idx + $1 + n) % n ))]}"
}

case "$1" in
    gui)
        barra-lateral --daemon
        for _ in $(seq 20); do
            qs -c sidebar ipc call fondos toggle >/dev/null 2>&1 && exit 0
            sleep 0.2
        done
        if command -v waypaper >/dev/null; then waypaper; else "$0" pick; fi ;;
    lista)
        list | while IFS= read -r f; do printf '%s\t%s\n' "$f" "$(miniatura "$f")"; done ;;
    miniaturas)
        mkdir -p "$THUMBS"
        exec 9>"$THUMBS/.lock"
        flock 9
        list | while IFS= read -r f; do
            t="$(miniatura "$f")"
            [ -s "$t" ] || printf '%s\0%s\0' "$f" "$t"
        done | xargs -0 -r -n2 -P2 sh -c \
            'nice -n19 vipsthumbnail "$0" -s 384x216 --smartcrop centre -o "$1[Q=82,strip]" 2>/dev/null' ;;
    pick)
        sel="$(list | sed "s|^$WALLDIR/||" | fuzzel --dmenu --prompt '󰸉  ' --width 50)"
        [ -n "$sel" ] && set_wall "$WALLDIR/$sel" ;;
    random)
        set_wall "$(list | grep -vxF "$(current)" | shuf -n1)" random ;;
    next) step 1 ;;
    prev) step -1 ;;
    set) set_wall "$2" ;;
    apply) apply "$2" ;;
    restore)
        f="$(current)"
        [ -f "$f" ] || f="$(list | head -n1)"
        ensure_daemon
        show "$f" none
        [ -f "$STATE" ] || apply "$f" ;;
    *) sed -n '2,10p' "$0"; exit 1 ;;
esac
