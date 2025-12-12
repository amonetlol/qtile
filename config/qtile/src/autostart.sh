#!/bin/sh
#nitrogen --restore &
#picom &
vmware-user suid wrapper &
numlockx &

if ! pgrep -x "polkit-gnome-au" > /dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# ===== WALLPAPER ALEATÓRIO COM FEH =====
WALLPAPER_DIR="$HOME/.config/qtile/walls"   # ou essa se preferir

feh --randomize --bg-fill "$WALLPAPER_DIR" &
