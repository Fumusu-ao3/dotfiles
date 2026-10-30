#!/usr/bin/env bash
dir="$HOME/Imágenes/Capturas"; mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

notificar() {
    pw-play /usr/share/sounds/freedesktop/stereo/camera-shutter.oga >/dev/null 2>&1 &
    (
        acciones=(-A abrir=Abrir -A carpeta="Ver carpeta")
        command -v satty >/dev/null && acciones=(-A editar=Editar "${acciones[@]}")
        r=$(notify-send -a Capturas -u low -i "$1" "${acciones[@]}" \
            "Captura ✧" "Guardada y copiada al portapapeles\n<small>${1##*/}</small>")
        case "$r" in
            editar)  "$0" editar "$1" ;;
            abrir)   xdg-open "$1" ;;
            carpeta) thunar "$dir" ;;
        esac
    ) >/dev/null 2>&1 &
    disown
}

editar() {
    rm -f "$2.tmp"
    satty --filename "$1" --output-filename "$2.tmp" --copy-command wl-copy || true
    [[ -s "$2.tmp" ]] && mv -f "$2.tmp" "$2"
}

case "$1" in
    full)
        grim "$file" || exit 1
        wl-copy < "$file"
        notificar "$file"
        ;;
    editar)
        [[ -f "$2" ]] || exit 1
        editar "$2" "$2" && notificar "$2"
        ;;
    *)
        geo="$(slurp -d -b '#00000055' -c '#ffffffcc' -w 2)" || exit 0
        if command -v satty >/dev/null; then
            tmp="$(mktemp --suffix=.png)"; trap 'rm -f "$tmp"' EXIT
            grim -g "$geo" "$tmp" || exit 1
            editar "$tmp" "$file" || exit 0
        else
            grim -g "$geo" "$file" || exit 1
            wl-copy < "$file"
        fi
        notificar "$file"
        ;;
esac
