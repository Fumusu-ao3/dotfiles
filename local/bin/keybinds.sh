#!/usr/bin/env bash
grep -E '^(bind|mousebind)=' ~/.config/mango/conf.d/binds.conf \
  | sed -E 's/^(bind|mousebind)=//; s/~\/\.local\/bin\///; s/^([^,]*),([^,]*),/\1 + \2  →  /; s/,/ /g' \
  | fuzzel --dmenu --prompt '  ' --width 70 --lines 20 >/dev/null
