#!/bin/bash
maxlength=24

playerctl metadata --follow --format '{{playerName}}|{{artist}} - {{title}}' | while IFS='|' read -r player text; do
    tooltip="$player : $text"

    if [ ${#text} -gt $maxlength ]; then
        text="${text:0:$((maxlength-3))}..."
    fi

    # Prints in the exact '< Artist - Title >' format
    echo "{\"text\": \"< $text >\", \"tooltip\": \"$tooltip\"}"
done