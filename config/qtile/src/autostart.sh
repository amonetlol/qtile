#!/bin/sh
#nitrogen --restore &
#picom &
vmware-user suid wrapper &
numlockx &

if ! pgrep -x "polkit-gnome-au" > /dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
