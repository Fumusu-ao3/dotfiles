#!/bin/bash
set -e
cd "$(dirname "$0")"

paquetes=(
  mangowm waybar quickshell swaync matugen awww waypaper
  foot fuzzel fastfetch starship btop cava yazi thunar
  wl-clipboard cliphist grim slurp satty wf-recorder ffmpeg imagemagick
  playerctl brightnessctl wireplumber pipewire-audio libnotify
  networkmanager bluez-utils power-profiles-daemon upower
  python-gobject gtk4-layer-shell hyprpolkitagent gnome-keyring
  kdeconnect android-tools scrcpy
  ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols ttf-nunito
)
sudo pacman -S --needed "${paquetes[@]}"
command -v yay >/dev/null && yay -S --needed bibata-cursor-theme-bin

copia=~/.config/backup-dotfiles-$(date +%F-%H%M)
for d in config/*; do
  n=$(basename "$d")
  if [ -e ~/.config/"$n" ]; then mkdir -p "$copia"; cp -r ~/.config/"$n" "$copia/"; fi
done
[ -d "$copia" ] && echo "lo que tenías quedó en $copia"

cp -r config/. ~/.config/
mkdir -p ~/.local/bin
cp local/bin/* ~/.local/bin/
sed -i "s#@HOME@#$HOME#g" ~/.config/swaync/config.json
touch ~/.config/mango/conf.d/colors.conf
mkdir -p ~/wallpapers ~/Imágenes/Barra ~/Imágenes/Capturas

if [ -n "$(ls -A ~/wallpapers)" ]; then
  ~/.local/bin/wallpaper.sh random || true
else
  echo "poné fondos en ~/wallpapers y después SUPER+T para elegir uno (los colores salen de ahí)"
fi
echo "listo, cerrá sesión y entrá a mango"
