#!/usr/bin/env bash
opts="  Bloquear\n󰍃  Cerrar sesión\n󰤄  Suspender\n  Reiniciar\n⏻  Apagar"
case "$(printf "$opts" | fuzzel --dmenu --prompt '⏻  ' --lines 5 --width 22)" in
    *Bloquear)  pgrep -f "qs -c lockscreen" >/dev/null || setsid -f qs -c lockscreen >/dev/null 2>&1 ;;
    *Cerrar*)   mmsg dispatch quit ;;
    *Suspender) systemctl suspend ;;
    *Reiniciar) systemctl reboot ;;
    *Apagar)    systemctl poweroff ;;
esac
