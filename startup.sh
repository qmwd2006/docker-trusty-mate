#!/bin/bash

#set -e

VNC_IP=$(ip addr show eth0 | grep -Po 'inet \K[\d.]+')
VNC_USER=${VNC_USER:-guest}
VNC_PW=${VNC_PW:-guest}
VNC_GEOMETRY=${VNC_GEOMETRY:-1440x900}
VNC_TZ=${VNC_TZ:-Asia/Hong_Kong}
VNC_LOCALE=${VNC_LOCALE:-zh_CN.UTF-8}

if ! id $VNC_USER >& /dev/null
then
    adduser --shell /bin/bash --gecos '' --disabled-password $VNC_USER
    adduser $VNC_USER sudo
    echo $VNC_USER:$VNC_PW | chpasswd
    su - $VNC_USER -c "echo -e \"\nexport TERM=xterm\nexport TZ=${VNC_TZ}\nexport LANG=${VNC_LOCALE}\n\" >> .bashrc"
fi

/etc/init.d/rsyslog restart
/etc/init.d/dbus start

su - $VNC_USER -c "[ ! -d .vnc ] && umask 077 && mkdir .vnc"
su - $VNC_USER -c "[ ! -f .vnc/passwd ] && umask 077 && echo $VNC_PW | vncpasswd -f > .vnc/passwd"

su - $VNC_USER -c "vncserver -kill :0"
rm -rf /tmp/.X0-lock
rm -rf /tmp/.X11-unix/X0
su - $VNC_USER -c "TZ=$VNC_TZ LANG=$VNC_LOCALE vncserver -nevershared -geometry $VNC_GEOMETRY :0"

echo
echo "-----------------------------------------------------"
echo "connect via vncviewer at $VNC_IP:5900"
echo "-----------------------------------------------------"
echo

su - $VNC_USER -c "tail -f .vnc/*0.log"
