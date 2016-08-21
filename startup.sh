#!/bin/bash

#set -e

VNC_IP=$(ip addr show eth0 | grep -Po 'inet \K[\d.]+')
VNC_USER=${VNC_USER:-guest}
VNC_PW=${VNC_PW:-guest}
VNC_GEOMETRY=${VNC_GEOMETRY:-1024x768}

if ! id $VNC_USER >& /dev/null
then
    adduser --shell /bin/bash --gecos '' --disabled-password $VNC_USER
    adduser $VNC_USER sudo
    echo $VNC_USER:$VNC_PW | chpasswd

    /etc/init.d/rsyslog start
    /etc/init.d/dbus start
fi

su - $VNC_USER -c "[ ! -d .vnc ] && umask 077 && mkdir .vnc"
su - $VNC_USER -c "[ ! -f .vnc/passwd ] && umask 077 && echo $VNC_PW | vncpasswd -f > .vnc/passwd"

su - $VNC_USER -c "vncserver -kill :0"
rm -rf /tmp/.X0-lock
rm -rf /tmp/.X11-unix/X0
su - $VNC_USER -c "vncserver -nevershared -geometry $VNC_GEOMETRY :0"

echo
echo "-----------------------------------------------------"
echo "connect via vncviewer at $VNC_IP:5900"
echo "-----------------------------------------------------"
echo

su - $VNC_USER -c "tail -f .vnc/*0.log"
