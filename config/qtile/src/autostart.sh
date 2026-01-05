#!/bin/sh
#nitrogen --restore &
#picom &
vmware-user suid wrapper &
numlockx &

# Gnome-polkit
if ! pgrep -x "polkit-gnome-au" > /dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi

# Mate-polkit
if ! pgrep -u "$USER" -x mate-polkit > /dev/null; then
    /usr/lib/mate-polkit/mate-polkit &
fi

# ===== WALLPAPER ALEATÓRIO COM FEH =====
#setfeh.sh &
sh ~/.fehbg

# === Polybar ===
. ~/.config/iSettings/themes/polybar.sh

